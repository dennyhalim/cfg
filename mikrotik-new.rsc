# dennyhalim.com relative secured mikrotik config kickstarter
# only partial tested
# only use this to completely re-configure your mikrotik
# ether1 WAN / internet, dhcp client, drop all
# ether2 LAN ip 10.20.30.1 , dhcp server, accept input
# servers ip 10.20.30.1-10.20.30.15 ( 10.20.30.0/28 )
# wlan1 10.20.31.1
# wlan_guest1 10.200.31.1

# WARNING: this will reset your router config!
# do backup before proceed!
# automatic setup, run these commands:
# /tool fetch url=https://raw.githubusercontent.com/dennyhalim/cfg/master/mikrotik-new.rsc
# /export file=[/system identity get name]
/system package update set channel=bugfix
# /system backup save #there will be auto-before-reset.backup
# manually run these, it will also reboot your router
# /system package update install
# /system reset-configuration no-defaults=yes #run-after-reset=mikrotik-new.rsc
# /import file=mikrotik-new.rsc verbose=yes

# or, manually copy-paste into mikrotik terminal
# after configured, change all passwords, keys, email, server_ip etc.
# test everything works.

#log system and accounts
/system logging
    add action=disk topics=account
    add action=disk topics=system

#only enable packages and services you need 
/tool bandwidth-server set enabled=no
#/system package 
#disable calea
#disable gps
#disable ipv6
#disable mpls
#disable multicast
#disable tr069-client
#disable ups
#disable user-manager 

/ip service
set api disabled=yes
set api-ssl disabled=yes
set ftp disabled=yes port=21001
set telnet disabled=yes port=23001

set ssh disabled=no port=22001
set www disabled=no port=8001
set www-ssl disabled=no port=631

#wireless config
/ip hotspot user profile set [find default=yes] rate-limit=1M/4M

/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk mode=\
    dynamic-keys wpa2-pre-shared-key=DennyHalim
add authentication-types=wpa2-psk mode=dynamic-keys name=wlan_guest1 \
    wpa2-pre-shared-key=dennyhalim.com

/interface wireless
set [ find default-name=wlan1 ] disabled=no mode=ap-bridge wps-mode=disabled \
    ssid=dennyhalim.com wireless-protocol=802.11 default-ap-tx-limit=4M
add disabled=no master-interface=wlan1 name=\
    wlan_guest1 security-profile=wlan_guest1 ssid="Wifi Guests" default-forwarding=no default-ap-tx-limit=1M

/interface bridge filter
add action=drop chain=forward in-interface=wlan_guest1
add action=drop chain=forward out-interface=wlan_guest1

#/ip settings set tcp-syncookies=yes
/ip neighbor discovery 
set ether1 discover=no
set wlan_guest1 discover=no

/ip address
add address=10.20.30.1/24 interface=ether2 network=10.20.30.0
add address=10.20.31.1/24 interface=wlan1 network=10.20.31.0
add address=10.200.31.1/24 interface=wlan_guest1 network=10.200.31.0
#if yourwan ip is static change disabled=yes and add wan ip

/ip dhcp-client add interface=ether1 use-peer-dns=no dhcp-options=hostname,clientid disabled=no

/ip pool
add name=pool_ether2 ranges=10.20.30.101-10.20.30.200
add name=wlan1 ranges=10.20.31.101-10.20.31.200
add name=wlan1_guest1 ranges=10.200.31.101-10.200.31.200

/ip dhcp-server
add add-arp=yes address-pool=pool_ether2 authoritative=after-2sec-delay \
    disabled=no interface=ether2 name=dhcp_ether2
add address-pool=wlan1 disabled=no interface=wlan1 name=wlan1
add address-pool=wlan1_guest1 disabled=no interface=wlan_guest1 name=wlan_guest1

#/ip dhcp-server network
#add address=10.20.30.0/24 gateway=10.20.30.1


/ip firewall nat
#servers ip 10.20.30.1-10.20.30.15 might access dns directly. others get redirected.
#     add chain=dstnat action=redirect protocol=udp src-address=!10.20.30.0/28 dst-port=53 nth=2,2 disabled=yes comment=redirect_to_local
     add chain=dstnat action=dst-nat protocol=udp src-address=!10.20.30.0/28 dst-port=53 to-addresses=185.228.168.10 to-port=5353 nth=2,2 disabled=no comment=redirect_to_cleanbrowsing
     add chain=dstnat action=dst-nat protocol=udp src-address=!10.20.30.0/28 dst-port=53 to-addresses=185.228.168.11 to-port=5353 nth=2,2 disabled=no comment=redirect_to_cleanbrowsing
     add chain=dstnat action=dst-nat protocol=udp src-address=!10.20.30.0/28 dst-port=53 to-addresses=208.67.222.123 to-port=443 nth=2,2 disabled=yes comment=redirect_to_opendns
     add chain=dstnat action=dst-nat protocol=udp src-address=!10.20.30.0/28 dst-port=53 to-addresses=208.67.222.123 to-port=443 nth=2,2 disabled=yes comment=redirect_to_opendns
#more secured? nat only certain ports (currently only for browsing and email.)
     add chain=srcnat action=masquerade src-address=10.20.30.0/24 out-interface=ether1 protocol=tcp dst-port=80,443,110,995,143,993,587,465
#enter dest-port to allow connections to certain udp ports
#     add chain=srcnat action=masquerade src-address=10.20.30.0/24 protocol=udp dst-port=
#servers allowed all ports
     add chain=srcnat action=masquerade src-address=10.20.30.0/28 out-interface=ether1

#change to disabled=no to nat all ports
     add chain=srcnat action=masquerade src-address=10.20.30.0/24 out-interface=ether1 disabled=yes

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

add action=drop chain=input in-interface=wlan_guest1
#drop all from WAN
add action=drop chain=input in-interface=ether1
add action=drop chain=input

/ip firewall filter
#block most attacked ports
add action=drop chain=forward protocol=tcp dst-port=23,25

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
add action=drop chain=input in-interface=wlan_guest1
#drop all from WAN
add action=drop chain=input in-interface=ether1
#drop everything else
### WARNING: THIS MIGHT BLOCK YOURSELF ###
###  enable it only if you're certain  ###
### also put this rule at most bottom! ###
add action=drop chain=input disabled=yes

#malware blocking dns 
# https://cleanbrowsing.org/ip-address
# https://dns.norton.com/faq.html
/ip dns
set allow-remote-requests=yes servers=\
    199.85.126.20,199.85.127.20,9.9.9.9,208.67.222.123,208.67.220.123,199.85.126.20,199.85.127.20
/ip dns static 
#your own wpad
#add ttl=1h address=your.wpad.server regexp=^wpad.*
#force strict safe search
add ttl=1h address=216.239.38.120 regexp=^www.google.co*
add ttl=1h address=216.239.38.119 name=www.youtube.com
add ttl=1h address=204.79.197.220 name=www.bing.com
#blocking advertising and other junks
add ttl=1h address=127.0.0.127 regexp=doubleclick.net
add ttl=1h address=127.0.0.127 name=www.googleadservices.com
add ttl=1h address=127.0.0.127 name=www.googlesyndication.com
add ttl=1h address=127.0.0.127 name=www.google-analytics.com
add ttl=1h address=127.0.0.127 name=www.googletagservices.com
#example blocking facebook, youtube
add ttl=1h address=127.0.0.127 regexp=pr0n disabled=yes
add ttl=1h address=127.0.0.127 regexp=fbcdn disabled=yes
add ttl=1h address=127.0.0.127 regexp=facebook disabled=yes
add ttl=1h address=127.0.0.127 regexp=youtube disabled=yes


/ip cloud 
    set ddns-enabled=yes
    get dns-name
    
/tool e-mail
set address=your_mail_server from=<mikrotik@dennyhalim.com>

/system script
add name=autobackup source=\
    ":global name=backupfile value=([/system identity get name].\".rsc\")\r\
    \n/export file=\$backupfile\r\
    \n:delay 20s\r\
    \n/tool e-mail send to=\"your@email.address\" subject=(\$backupfile) file=\$backupfile\r\
    \n/tool fetch address=your_ftp_server_ip src-path=\$backupfile user=your_ftp_username \
    mode=ftp password=your_ftp_password dst-path=\"/home/your_ftp_username/\$backupfile\" upload=yes\r\n"

/system scheduler
add interval=3h name=ipcloud on-event="/ip cloud force-update\r\n"
add interval=10d name=autobackup on-event=autobackup

/system ntp client set primary-ntp=87.124.126.49 secondary-ntp=204.9.54.119 enabled=yes \
    server-dns-names=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org
#/system script run autobackup

/system reboot
