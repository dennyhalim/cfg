#!/bin/bash
# based on script from http://www.axllent.org/docs/view/ssh-geoip
#rhel: yum install GeoIP
#ubuntu: apt-get install geoip-bin geoip-database 
#chmod +x /usr/local/bin/ipfilter.sh 
#make sure you have physical access to server in case you lock yourself, then add to /etc/hosts.deny
#sshd: ALL: aclexec /usr/local/bin/ipfilter.sh %a
#sshd: ALL: DENY

# UPPERCASE space-separated country codes to ACCEPT
ALLOW_COUNTRIES="ID"
LOGDENY_FACILITY="authpriv.notice"

if [ $# -ne 1 ]; then
  echo "Usage:  `basename $0` <ip>" 1>&2
  exit 0 # return true in case of config issue
fi

if [[ "`echo $1 | grep ':'`" != "" ]] ; then
  COUNTRY=`/usr/bin/geoiplookup6 "$1" | awk -F ": " '{ print $2 }' | awk -F "," '{ print $1 }' | head -n 1`
else
  COUNTRY=`/usr/bin/geoiplookup "$1" | awk -F ": " '{ print $2 }' | awk -F "," '{ print $1 }' | head -n 1`
fi
[[ $COUNTRY = "IP Address not found" || $ALLOW_COUNTRIES =~ $COUNTRY ]] && RESPONSE="ALLOW" || RESPONSE="DENY"

if [[ "$RESPONSE" == "ALLOW" ]] ; then
  exit 0
else
  logger -p $LOGDENY_FACILITY "$RESPONSE sshd connection from $1 ($COUNTRY)"
  exit 1
fi
