# jan/02/1970 00:04:23 by RouterOS 6.44.5
# software id = QSHR-CTXA
#
# model = 951G-2HnD
# serial number = 
/interface bridge
add name=bridge1
/interface wireless
set [ find default-name=wlan1 ] disabled=no mode=ap-bridge ssid=\
    dennyhalim.com wireless-protocol=802.11
/interface list
add name=WAN
add name=LAN
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa-psk,wpa2-psk mode=\
    dynamic-keys supplicant-identity=MikroTik wpa-pre-shared-key=\
    dennyhalim.com wpa2-pre-shared-key=dennyhalim.com
add authentication-types=wpa-psk,wpa2-psk mode=dynamic-keys name=profile \
    supplicant-identity=MikroTik wpa-pre-shared-key=dennyhalim.com \
    wpa2-pre-shared-key=dennyhalim.com
/interface wireless
add disabled=no mac-address=BA:69:F4:9D:EC:E1 master-interface=wlan1 name=\
    wlan2 security-profile=profile ssid="dennyhalim.com Guests"
/ip pool
add name=dhcp ranges=10.20.30.101-10.20.30.200
add name=vpn ranges=192.168.89.2-192.168.89.255
/ip dhcp-server
add address-pool=dhcp disabled=no interface=bridge1 name=dhcp1
/ppp profile
set *FFFFFFFE local-address=192.168.89.1 remote-address=vpn
/interface bridge filter
add action=drop chain=forward in-interface=wlan2
add action=drop chain=forward out-interface=wlan2
/interface bridge port
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3
add bridge=bridge1 interface=ether4
add bridge=bridge1 interface=ether5
add bridge=bridge1 interface=wlan1
add bridge=bridge1 interface=wlan2
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface l2tp-server server
set enabled=yes ipsec-secret=dennyhalim.com use-ipsec=yes
/interface list member
add interface=ether1 list=WAN
add interface=bridge1 list=LAN
/interface pptp-server server
set enabled=yes
/interface sstp-server server
set default-profile=default-encryption enabled=yes
/interface wireless access-list
add ap-tx-limit=2000000 interface=wlan2
/ip address
add address=10.20.30.254/24 interface=ether2 network=10.20.30.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add dhcp-options=hostname,clientid disabled=no interface=ether1
/ip dhcp-server network
add address=10.20.30.0/24 gateway=10.20.30.254 netmask=24
/ip firewall filter
add action=accept chain=input protocol=icmp
add action=accept chain=input connection-state=established
add action=accept chain=input connection-state=related
add action=accept chain=input comment="allow IPsec NAT" dst-port=4500 \
    protocol=udp
add action=accept chain=input comment="allow IKE" dst-port=500 protocol=udp
add action=accept chain=input comment="allow l2tp" dst-port=1701 protocol=udp
add action=accept chain=input comment="allow pptp" dst-port=1723 protocol=tcp
add action=accept chain=input comment="allow sstp" dst-port=443 protocol=tcp
add action=drop chain=input in-interface-list=!LAN
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN
add action=masquerade chain=srcnat comment="masq. vpn traffic" src-address=\
    192.168.89.0/24
/ppp secret
add name=vpn password=dennyhalim.com
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
