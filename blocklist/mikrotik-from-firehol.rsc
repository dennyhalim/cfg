/system script
add name=firehol source="/tool fetch url=\"http://myserver/bl/firehol.rsc\" mode=http;\r\
    \n/import file-name=firehol.rsc;\r\
    \n:log info \"FIREHOL update\";\r\
    \n"

/system scheduler
add interval=1d name=blacklist on-event="/system script run firehol"

/ip firewall filter
#you might want to move these rules to the top
add action=drop chain=forward comment=blacklist in-interface-list=WAN log=yes \
    log-prefix=blacklist src-address-list=blacklist
add action=drop chain=forward comment=blacklist dst-address-list=blacklist log=yes \
    log-prefix=blacklist out-interface-list=WAN

