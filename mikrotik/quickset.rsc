# jan/02/1970 00:08:03 by RouterOS 6.39.2
# software id = 664V-FA18
#
/interface bridge
add name=bridge2
/interface wireless
set [ find default-name=wlan1 ] disabled=no mode=ap-bridge ssid=\
    dennyhalim.com wireless-protocol=802.11
/ip neighbor discovery
set ether1 discover=no
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa-psk,wpa2-psk mode=\
    dynamic-keys wpa-pre-shared-key=DennyHalim wpa2-pre-shared-key=DennyHalim
add authentication-types=wpa-psk,wpa2-psk mode=dynamic-keys name=profile \
    wpa-pre-shared-key=dennyhalim.com wpa2-pre-shared-key=dennyhalim.com
/interface wireless
add disabled=no mac-address=66:D1:54:F4:CE:F4 master-interface=wlan1 name=\
    wlan2 security-profile=profile ssid="Wifi Guests"
/ip pool
add name=dhcp ranges=10.20.30.101-10.20.30.200
add name=vpn ranges=192.168.89.2-192.168.89.255
/ip dhcp-server
add address-pool=dhcp disabled=no interface=bridge2 name=dhcp1
/ppp profile
set *FFFFFFFE local-address=192.168.89.1 remote-address=vpn
/interface bridge filter
add action=drop chain=forward in-interface=wlan2
add action=drop chain=forward out-interface=wlan2
/interface bridge port
add bridge=bridge2 interface=ether2
add bridge=bridge2 interface=ether3
add bridge=bridge2 interface=ether4
add bridge=bridge2 interface=wlan1
add bridge=bridge2 interface=wlan2
/interface l2tp-server server
set enabled=yes ipsec-secret=DennyHalim use-ipsec=yes
/interface pptp-server server
set enabled=yes
/interface sstp-server server
set default-profile=default-encryption enabled=yes
/interface wireless access-list
add ap-tx-limit=104 interface=wlan2
/ip address
add address=10.20.30.1/24 interface=ether2 network=10.20.30.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add dhcp-options=hostname,clientid disabled=no interface=ether1
/ip dhcp-server network
add address=10.20.30.0/24 gateway=10.20.30.1 netmask=24
/ip firewall filter
add action=accept chain=input protocol=icmp
add action=accept chain=input connection-state=established
add action=accept chain=input connection-state=related
add action=accept chain=input comment="allow l2tp" dst-port=1701 protocol=udp
add action=accept chain=input comment="allow pptp" dst-port=1723 protocol=tcp
add action=accept chain=input comment="allow sstp" dst-port=443 protocol=tcp
add action=drop chain=input in-interface=ether1
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
add action=masquerade chain=srcnat comment="masq. vpn traffic" src-address=\
    192.168.89.0/24
/ppp secret
add name=vpn password=DennyHalim
/tool mac-server
set [ find default=yes ] disabled=yes
add interface=ether2
add interface=ether3
add interface=ether4
add interface=wlan1
add interface=wlan2
/tool mac-server mac-winbox
set [ find default=yes ] disabled=yes
add interface=ether2
add interface=ether3
add interface=ether4
add interface=wlan1
add interface=wlan2
