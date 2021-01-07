#!/bin/bash
# Inspired by Joshaven Potter
# http://joshaven.com/resources/tricks/mikrotik-automatically-updated-address-list/
DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

saveTo=/var/www/html/bl/firehol.rsc
now=$(date);
echo "# Generated on $now" > $saveTo
echo "/ip firewall address-list" >> $saveTo
#wget -q -O -  https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset | awk --posix '/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0\t/ { print "add list=blacklist timeout=23h59m address=" $1 "/24 comment=firehol";}' >> $saveTo
wget -q -O -  https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset | awk --posix '/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ { print "add list=blacklist  timeout=23h59m address=" $1 " comment=firehol";}' >> $saveTo

