#!/bin/bash
#denny.wordpress.com
#add this on top of /etc/pam.d/sshd
#auth [success=ok default=1] pam_exec.so quiet /usr/local/sbin/chdnsbl
#auth requisite pam_deny.so
#
IP=${1:-$PAM_RHOST}
IP=$(echo $IP | awk '{print $1}')
LOG=/var/log/dnsbl.log
WL=/etc/dnsbl.whitelist
[ -z "$IP" ] && exit 1

# 1. WHITELIST - exact or CIDR prefix check
if [ -f "$WL" ]; then
  grep -qx "$IP" "$WL" 2>/dev/null && exit 1
  # prefix match like 192.168.13.
  while read -r p; do
    [[ "$p" =~ ^# || -z "$p" ]] && continue
    [[ "$IP" == "$p"* ]] && exit 1
  done < "$WL"
fi

# 2. SKIP private/local - always ALLOW
case "$IP" in
  10.*|192.168.*|172.1[6-9].*|172.2[0-9].*|172.3[0-1].*|127.*|::1|::ffff:*|fe80:*|fc00:*|fd00:*) exit 1;;
esac

# IPv6 - no DNSBL check for now, allow
[[ "$IP" == *:* ]] && exit 1

R=$(echo $IP | awk -F. '{if(NF==4) print $4"."$3"."$2"."$1; else print ""}')
[ -z "$R" ] && exit 1

# 3. MULTI DNSBL LIST - edit here
BL="
dnsbl.dronebl.org
bl.spamcop.net
cbl.abuseat.org
b.barracudacentral.org
dnsbl.sorbs.net
"

for zone in $BL; do
  [[ "$zone" =~ ^# || -z "$zone" ]] && continue
  if result=$(dig +short +time=2 +tries=1 $R.$zone 2>/dev/null | grep "^127\."); then
    echo "$(date '+%Y-%m-%d %H:%M:%S') DENY $IP in $zone -> $result" >> $LOG
    exit 0
  fi
done

exit 1
