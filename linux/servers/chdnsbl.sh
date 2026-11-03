#!/bin/bash
# Unified - works for PAM and tcpwrapper
# denny.wordpress.com
#
# add this to /etc/hosts.allow
# ALL: ALL: aclexec /usr/local/sbin/chdnsbl.sh %a : spawn /bin/echo "DENY %a %d"
# 
# add this on top /etc/pam.d/sshd
# auth [success=1 default=ok] pam_exec.so /usr/local/sbin/chdnsbl.sh
# auth requisite pam_deny.so


# Detect caller
if [ -n "$PAM_RHOST" ]; then
  MODE="pam"
  IP=$(echo $PAM_RHOST | awk '{print $1}')
  PAM_ALLOW=0  # PAM: 0=allow, 1=deny
  PAM_DENY=1
else
  MODE="tcpd"
  IP=$1
  TCPD_ALLOW=1  # tcpd aclexec: 1=allow, 0=deny
  TCPD_DENY=0
fi
[ -z "$IP" ] && IP=$1

WL=/etc/dnsbl.whitelist
LOG=/var/log/dnsbl.log

# whitelist/private
grep -qx "$IP" "$WL" 2>/dev/null && { [ "$MODE" = "pam" ] && exit $PAM_ALLOW || exit $TCPD_ALLOW; }
#case "$IP" in 10.*|192.168.*|127.*) [ "$MODE" = "pam" ] && exit $PAM_ALLOW || exit $TCPD_ALLOW;; esac

R=$(echo $IP | awk -F. '{if(NF==4) print $4"."$3"."$2"."$1; else print ""}')
[ -z "$R" ] && { [ "$MODE" = "pam" ] && exit $PAM_ALLOW || exit $TCPD_ALLOW; }

# check
IS_LISTED=0
for zone in dnsbl.dronebl.org dnsbl-3.uceprotect.net dnsbl.sorbs.net combined.abuse.ch bl.spamcop.net b.barracudacentral.org; do
  #if dig +short +time=2 $R.$zone 2>/dev/null | grep -q "^127\."; then
  if result=$(dig +short +time=2 $R.$zone 2>/dev/null | grep "^127\."); then
    IS_LISTED=1; ZONE=$zone; break
  fi
done

if [ $IS_LISTED -eq 1 ]; then
  echo "$(date) DENY $IP in $ZONE mode=$MODE" - $result | tee $LOG
  logger -t sshd -p auth.err "DNSBL DENY $IP in $ZONE mode=$MODE - $result"
  [ "$MODE" = "pam" ] && exit $PAM_DENY || exit $TCPD_DENY
else
  [ "$MODE" = "pam" ] && exit $PAM_ALLOW || exit $TCPD_ALLOW
fi
