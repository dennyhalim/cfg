#!/bin/bash
# Inspired by Joshaven Potter
# http://joshaven.com/resources/tricks/mikrotik-automatically-updated-address-list/
# dennyhalim.com
# example usage: save this file in /opt/bin/firehol.sh
# then add this line to 'sudo crontab -e' :
# 0 5 * * * /bin/bash /opt/bin/firehol.sh

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

saveTo=/var/www/html/bl/firehol.rsc
now=$(date);
echo "# Generated on $now" > $saveTo
echo "/ip firewall address-list remove [find where list=blacklist]" >> $saveTo
echo "/ip firewall address-list" >> $saveTo
#wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset | awk --posix '/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ { print "add list=blacklist timeout=23h59m50s address=" $1 " comment=dennyhalim-firehol-script";}' >> $saveTo

echo "#fh1"  >> $saveTo
wget -q -O - https://iplists.firehol.org/files/firehol_level1.netset | grep -vxf /root/IPLAN.txt | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "add list=blacklist address=" $1 " timeout=1d comment=bl:fh1";}' >> $saveTo

echo "#fh2"  >> $saveTo
wget -q -O - https://iplists.firehol.org/files/firehol_level2.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "add list=blacklist address=" $1 " timeout=1d comment=bl:fh2";}' >> $saveTo

