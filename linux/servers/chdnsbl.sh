#!/bin/bash
#denny.wordpress.com
#add this on top of /etc/pam.d/sshd
#auth [success=1 default=ok] pam_exec.so quiet /usr/local/sbin/checkdnsbl
#auth requisite pam_deny.so
#
IP=${1:-$PAM_RHOST}; IP=$(echo $IP | awk '{print $1}')
LOG=/var/log/dnsbl.log
WL=/etc/dnsbl.whitelist
[ -z "$IP" ] && exit 0
grep -qx "$IP" "$WL" 2>/dev/null && exit 0
case "$IP" in 10.*|192.168.*|172.1[6-9].*|172.2*|172.3*|127.*|::1|::*) exit 0;; esac
[[ "$IP" == *:* ]] && exit 0
R=$(echo $IP | awk -F. '{if(NF==4) print $4"."$3"."$2"."$1; else print ""}'); [ -z "$R" ] && exit 0
for zone in dnsbl.dronebl.org bl.spamcop.net cbl.abuseat.org b.barracudacentral.org; do
  if dig +short +time=2 $R.$zone 2>/dev/null | grep -q "^127\."; then
    echo "$(date) DENY $IP in $zone" >> $LOG
    exit 1
  fi
done
exit 0
