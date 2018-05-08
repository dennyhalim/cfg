# dennyhalim.com relative secured mikrotik config kickstarter
# NOT TESTED
# only use this to completely re-configure your mikrotik
# ether1 WAN / internet, dhcp client, drop all
# ether2 LAN ip 10.20.30.1 , dhcp server, accept input
# servers ip 10.20.30.1-10.20.30.15 ( 10.20.30.0/28 )

#usage:
#1. upgrade firmware and reboot and make sure everything runs fine
#2. reset mikrotik 
#   /system reset-configuration no-defaults=yes
#3. reconnect using MAC address
#4. copy-paste this into mikrotik terminal
#5. change password (system menu) and wireless wpa2-pre-shared-key / ssid
#6. test, make sure everything runs fine

#only enable packages and services you need 
/system package disable calea,gps,mpls,multicast,tr069-client,ups,user-manager 

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=no
set ssh disabled=no
set api disabled=yes
set api-ssl disabled=yes

#wireless config
/interface wireless
set [ find default-name=wlan1 ] disabled=no mode=ap-bridge ssid=\
    dennyhalim.com wireless-protocol=802.11 default-ap-tx-limit=4M
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk mode=\
    dynamic-keys wpa2-pre-shared-key=DennyHalim
add authentication-types=wpa2-psk mode=dynamic-keys name=profile \
    wpa2-pre-shared-key=dennyhalim.com
/interface wireless
add disabled=no master-interface=wlan1 name=\
    wlan_guest1 security-profile=profile ssid="Wifi Guests" default-forwarding=no default-ap-tx-limit=1M
/interface bridge filter
add action=drop chain=forward in-interface=wlan_guest1
add action=drop chain=forward out-interface=wlan_guest1

/ip hotspot user profile set [find default=yes] rate-limit=200k/1M
#/ip settings set tcp-syncookies=yes
/ip neighbor discovery 
set ether1 discover=no
set wlan_guest1 discover=no

/ip address
add address=10.20.30.1/24 interface=ether2 network=10.20.30.0
#if yourwan ip is static change disabled=yes and add wan ip
/ip dhcp-client add interface=ether1 use-peer-dns=no dhcp-options=hostname,clientid disabled=no

/ip pool
add name=pool_ether2 ranges=10.20.30.101-10.20.30.200
/ip dhcp-server
add add-arp=yes address-pool=pool_ether2 authoritative=after-2sec-delay \
    disabled=no interface=ether2 name=dhcp_ether2
/ip dhcp-server network
add address=10.20.30.0/24 gateway=10.20.30.1


/ip firewall nat
#ip 10.20.30.1-10.20.30.15 might access dns directly. others get redirected.
      chain=dstnat action=redirect protocol=udp src-address=!10.20.30.0/28 dst-port=53 
#more secured, nat only certain ports (currently only for browsing and email.)
      chain=srcnat action=masquerade src-address=10.20.30.0/24 out-interface=ether1 protocol=tcp dst-port=80,443,110,995,143,993,587,465
#      chain=srcnat action=masquerade src-address=10.20.30.0/24 protocol=udp dst-port=
#servers allowed all ports
      chain=srcnat action=masquerade src-address=10.20.30.0/28 out-interface=ether1
#change to disabled=no to nat all ports
      chain=srcnat action=masquerade src-address=10.20.30.0/24 out-interface=ether1 disabled=yes

##FIREWALL
#first, drop ddos and bad stuffs
#https://wiki.mikrotik.com/wiki/DDoS_Detection_and_Blocking
/ip settings set rp-filter=loose
/ip firewall mangle add action=mark-routing chain=prerouting dst-address-list=ddosed new-routing-mark=ddoser-route-mark passthrough=no src-address-list=ddoser
/ip route add distance=254 routing-mark=ddoser-route-mark type=blackhole

/ipv6 firewall filter
add chain=forward connection-state=new action=jump jump-target=block-ddos
add chain=forward connection-state=new src-address-list=ddoser dst-address-list=ddosed action=drop
add chain=block-ddos dst-limit=50,50,src-and-dst-addresses/10s action=return
add chain=block-ddos action=add-dst-to-address-list address-list=ddosed address-list-timeout=10m
add chain=block-ddos action=add-src-to-address-list address-list=ddoser address-list-timeout=10m

add action=drop chain=forward in-interface=wlan_guest1 out-interface=!ether1
add action=drop chain=input comment="Drop Invalid Input" \
    connection-state=invalid
add action=drop chain=forward comment="Drop Invalid Forward" \
    connection-state=invalid
#add chain=forward protocol=tcp tcp-flags=syn connection-limit=200,32 action=drop comment="too much connections"


/ip firewall filter
add chain=forward connection-state=new action=jump jump-target=block-ddos
add chain=forward connection-state=new src-address-list=ddoser dst-address-list=ddosed action=drop
add chain=block-ddos dst-limit=50,50,src-and-dst-addresses/10s action=return
add chain=block-ddos action=add-dst-to-address-list address-list=ddosed address-list-timeout=10m
add chain=block-ddos action=add-src-to-address-list address-list=ddoser address-list-timeout=10m

add action=accept chain=input comment="allow remote" dst-port=\
    22,80,8291 log-prefix=remoting protocol=tcp
#first, drop bad stuffs
add action=drop chain=forward in-interface=wlan_guest1 out-interface=!ether1
add action=drop chain=input comment="Drop Invalid Input" \
    connection-state=invalid
add action=drop chain=forward comment="Drop Invalid Forward" \
    connection-state=invalid
#add chain=forward protocol=tcp tcp-flags=syn connection-limit=200,32 action=drop comment="too much connections"
#allowances
add action=accept chain=input comment="Allow ICMP" protocol=icmp
add action=accept chain=input comment="Allow Established Input" \
    connection-state=established
add action=accept chain=forward comment="Allow Established Forward" \
    connection-state=established
add action=accept chain=forward comment="Allow Related" \
    connection-state=related
#add action=drop chain=input src-address-type=broadcast
#add action=drop chain=input dst-address-type=broadcast
add action=drop chain=input dst-address=255.255.255.255
add action=drop chain=input dst-address=10.20.30.255
### dont forget to replace the interfaces names
add action=accept chain=input comment="allow from lan" in-interface=ether2
#add action=accept chain=input comment="allow from vlan" in-interface=vlan1
#add action=accept chain=input comment=capman in-interface=capman1
#add action=accept chain=forward comment="Allow new connections through router coming in LAN interface" \
#    connection-state=new in-interface=ether2
#drop all from WAN
add action=drop chain=input in-interface=ether1
#drop everything else
### WARNING: THIS MIGHT BLOCK YOURSELF ###
###  enable it only if you're certain  ###
### also put this rule at most bottom! ###
add action=drop chain=input

#malware blocking dns
/ip dns
set allow-remote-requests=yes servers=\
    9.9.9.9,199.85.126.20,208.67.222.123,208.67.220.123,199.85.127.20
/ip dns static 
#force strict safe search
add ttl=1h address=216.239.38.120 regexp=www.google.co*
add ttl=1h address=216.239.38.119 name=www.youtube.com
add ttl=1h address=204.79.197.220 name=www.bing.com
#blocking advertising and other junks
add ttl=1h address=127.0.0.127 regexp=doubleclick.net
add ttl=1h address=127.0.0.127 name=www.googleadservices.com
add ttl=1h address=127.0.0.127 name=www.googlesyndication.com
add ttl=1h address=127.0.0.127 name=www.google-analytics.com
add ttl=1h address=127.0.0.127 name=www.googletagservices.com
#example blocking facebook, youtube
add ttl=1h address=127.0.0.127 regexp=facebook disabled=yes
add ttl=1h address=127.0.0.127 regexp=youtube disabled=yes


/ip cloud 
    set ddns-enabled=yes
    get dns-name
    
/system reboot
