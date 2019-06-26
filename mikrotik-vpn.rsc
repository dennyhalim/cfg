# default mikrotik vpn config
# jan/02/1970 00:04:26 by RouterOS 6.43.16
# software id = 9P7C-HIT1
#
# model = 750UP
# serial number = 468F02D1AACC
/interface list
add name=WAN
add name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=vpn ranges=192.168.89.2-192.168.89.255
/ppp profile
set *FFFFFFFE local-address=192.168.89.1 remote-address=vpn
/interface l2tp-server server
set enabled=yes ipsec-secret=agci09876 use-ipsec=yes
/interface list member
add interface=ether1 list=WAN
add list=LAN
/interface pptp-server server
set enabled=yes
/interface sstp-server server
set default-profile=default-encryption enabled=yes
/ip address
add address=192.168.102.19/22 interface=ether2 network=192.168.100.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add dhcp-options=hostname,clientid disabled=no interface=ether1
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN
add action=masquerade chain=srcnat comment="masq. vpn traffic" src-address=\
    192.168.89.0/24
/ppp secret
add name=vpn password=agci09876
/system identity
set name=vpn02
