# NOT TESTED
# only use this to completely re-configure your mikrotik
# ether1 LAN ip 10.20.30.1 , dhcp server, accept input
# ether2 WAN / internet, dhcp client, drop all

#usage:
#1. upgrade firmware and reboot and make sure everything runs fine
#2. reset mikrotik
#3. remove configuration
#4. copy-paste this into mikrotik terminal
#5. change password (system menu)
#6. reboot, make sure everything runs fine

/ip address
add address=10.20.30.1/24 interface=ether1 network=10.20.30.0
#if your wan ip is static change disabled=yes and add wan ip
/ip dhcp-client add interface=ether2 disabled=no

/ip pool
add name=pool_ether1 ranges=10.20.30.101-10.20.30.200
/ip dhcp-server
add add-arp=yes address-pool=pool_ether1 authoritative=after-2sec-delay \
    disabled=no interface=ether1 name=dhcp_ether1
/ip dhcp-server network
add address=10.20.30.0/24 gateway=10.20.30.1

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=no
set ssh disabled=no
set api disabled=yes
set api-ssl disabled=yes

##FIREWALL
/ip firewall filter
add action=accept chain=input comment="allow remote" dst-port=\
    22,80,8291 log-prefix=remoting protocol=tcp
#first, drop bad stuffs
add action=drop chain=input comment="Drop Invalid input" \
    connection-state=invalid
add action=drop chain=forward comment="drop invalid forward" \
    connection-state=invalid
add chain=forward protocol=tcp tcp-flags=syn connection-limit=101,32 action=drop
#allowances
add action=accept chain=input comment="Allow ICMP" protocol=icmp
add action=accept chain=input comment="Allow Established input" \
    connection-state=established
add action=accept chain=forward comment="allow established forward" \
    connection-state=established
add action=accept chain=forward comment="allow related" \
    connection-state=related
#add action=drop chain=input src-address-type=broadcast
#add action=drop chain=input dst-address-type=broadcast
#add action=drop chain=input dst-address=255.255.255.255
#add action=drop chain=input dst-address=192.168.1.255
### dont forget to replace the interfaces names
add action=accept chain=input comment="allow from lan" in-interface=ether1
#add action=accept chain=input comment="allow from vlan" in-interface=vlan1
#add action=accept chain=input comment=capman in-interface=capman1
#add action=accept chain=forward comment="Allow new connections through router coming in LAN interface" connection-state=new \
   in-interface=ether1
#drop all from WAN
add action=drop chain=input in-interface=ether2
#drop everything else
### WARNING: THIS MIGHT BLOCK YOURSELF ###
###  enable it only if you're certain  ###
### also put this rule at most bottom! ###
add action=drop chain=input

/ip firewall nat
#ip 10.20.30.1-10.20.30.15 might access dns directly. others get blocked.
      chain=dstnat action=redirect protocol=udp src-address=!10.20.30.0/28 dst-port=53 
      chain=srcnat action=masquerade src-address=10.20.30.0/24 

#malware blocking dns
/ip dns
set allow-remote-requests=yes servers=\
    9.9.9.9,199.85.126.20,208.67.222.123,208.67.220.123,199.85.127.20
/ip dns static 
#force strict safe search
add ttl=1h address=216.239.38.120 regexp=www.google.co*
add ttl=1h address=216.239.38.120 name=www.youtube.com
add ttl=1h address=204.79.197.220 name=www.bing.com
#blocking stuffs
add ttl=1h address=127.0.0.127 regexp=*.doubleclick.net
add ttl=1h address=127.0.0.127 name=www.googleadservices.com
add ttl=1h address=127.0.0.127 name=www.googlesyndication.com
add ttl=1h address=127.0.0.127 name=www.google-analytics.com
add ttl=1h address=127.0.0.127 name=www.googletagservices.com
