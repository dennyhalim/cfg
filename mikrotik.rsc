##FIREWALL
/ip firewall filter
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
add action=accept chain=input comment="Allow ICMP" protocol=icmp
add action=accept chain=input comment="Allow Established input" \
    connection-state=established
add action=accept chain=forward comment="allow established forward" \
    connection-state=established
add action=accept chain=forward comment="allow related" \
    connection-state=related
add action=accept chain=input comment="allow from lan" in-interface=lan1-interface
add action=accept chain=input comment="allow from vlan" in-interface=vlan1-interface
add action=accept chain=input comment=capman in-interface=capman1-interface
#drop all from ip public
add action=drop chain=input in-interface=public1-interface
#drop everything else
### WARNING: THIS MIGHT BLOCK YOURSELF ###
add action=drop chain=input
