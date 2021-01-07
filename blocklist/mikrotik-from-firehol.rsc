/system script
add name=firehol sol fetch url=\"http://myserver/bl/firehol.rsc\" mode=http;\
    \n/import file-name=spamhaus.rsc;\r\
    \n:log info \"SPAMHAUS update\";\r\
    \n"

/system scheduler
add interval=1d name=blacklist on-event="/system script run firehol"

/ip firewall filter
add action=drop chain=forward comment=blacklist in-interface-list=WAN log=yes \
    log-prefix=blacklist src-address-list=blacklist
add action=drop chain=forward comment=blacklist dst-address-list=blacklist log=yes \
    log-prefix=blacklist out-interface-list=WAN

