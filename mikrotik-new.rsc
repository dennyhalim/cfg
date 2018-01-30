# NOT TESTED
# ONLY USE ON NEW MIKROTIK
# ether1 LAN ip 10.20.30.1
# ether2 WAN / internet, dhcp client

/ip address
add address=10.20.30.1/24 interface=ether1 network=10.20.30.0
/ip dhcp-client add interface=ether2

/ip pool
add name=pool_ether1 ranges=10.20.30.101-10.20.30.200
/ip dhcp-server
add add-arp=yes address-pool=pool_ether1 authoritative=after-2sec-delay \
    disabled=no interface=ether1 name=dhcp_ether1

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=no
set ssh disabled=no
set api disabled=yes
set api-ssl disabled=yes

##FIREWALL
/ip firewall filter
#first, drop bad stuffs
add action=accept chain=input comment="allow remote" dst-port=\
    22,80,8291 log-prefix=rmt protocol=tcp
#add action=drop chain=input src-address-type=broadcast
#add action=drop chain=input dst-address-type=broadcast
#add action=drop chain=input dst-address=255.255.255.255
#add action=drop chain=input dst-address=192.168.1.255
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
### dont forget to replace the interfaces names
add action=accept chain=input comment="allow from lan" in-interface=ether1
#add action=accept chain=input comment="allow from vlan" in-interface=vlan1
#add action=accept chain=input comment=capman in-interface=capman1
#add action=accept chain=forward comment="Allow new connections through router coming in LAN interface" connection-state=new \
   in-interface=ether1
#drop all from ip public
add action=drop chain=input in-interface=ether2
#drop everything else
### WARNING: THIS MIGHT BLOCK YOURSELF ###
###  enable it only if you're certain  ###
### also put this rule at most bottom! ###
add action=drop chain=input
