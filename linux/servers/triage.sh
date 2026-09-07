#!/bin/sh
# Linux Triage - POSIX version. Works in sh, bash, dash
OUTDIR="/root/triage_$(hostname)_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
LOG="$OUTDIR/triage.log"

log() { echo "[+] $1" | tee -a "$LOG"; }

log "=========================================="
log "Linux Triage - 20 Steps. Output: $OUTDIR"
log "Date: $(date)"
log "=========================================="

OFFICE_IPS="YOUR.OFFICE.IP\|10\.0\.\|192\.168\.\|172\.16\."

# 1
log "1. Who is logged in"
timeout 5 sh -c "who > $OUTDIR/who.txt; w >> $OUTDIR/who.txt; last -n 200 > $OUT                                                                                       DIR/last_logins.txt" 2>/dev/null || log "step 1 timeout"

# 2
log "2. Top CPU/MEM processes"
timeout 5 ps aux --sort=-%cpu | head -100 > "$OUTDIR/top_cpu.txt"
timeout 5 ps aux --sort=-%mem | head -100 > "$OUTDIR/top_mem.txt"

# 3. NETWORK CONNECTIONS - ONLY EXTERNAL TO EXTERNAL
log "3. Network connections"

# All listening
timeout 10 ss -plant > "$OUTDIR/ss_listen_all.txt" 2>/dev/null

# External listeners only: remove 127.0.0.1, ::1, [::1]
awk 'NR==1 || ($5!~ /127\.0\.0\.1/ && $5!~ /::1/ && $5!~ /\[::1\]/)' "$OUTDIR/ss                                                                                       _listen_all.txt" > "$OUTDIR/ss_external_listen.txt"

# All established
timeout 10 ss -tunap state established > "$OUTDIR/ss_established_all.txt" 2>/dev                                                                                       /null

# External established only: local NOT localhost AND peer NOT localhost AND peer                                                                                       != local
awk '
NR==1 {print; next}
{
    split($4,a,":"); local_ip=a[1]
    split($5,b,":"); peer_ip=b[1]

    # skip if local is localhost
    if(local_ip=="127.0.0.1" || local_ip=="::1" || local_ip=="[::1]") next

    # skip if peer is localhost
    if(peer_ip=="127.0.0.1" || peer_ip=="::1" || peer_ip=="[::1]") next

    # skip if peer == local (connections to self)
    if(local_ip==peer_ip) next

    # skip DNS and NTP
    if($5 ~ /:53$/ || $5 ~ /:123$/) next

    print
}' "$OUTDIR/ss_established_all.txt" > "$OUTDIR/ss_established_external.txt"

# 4
log "4. Auth logs"
grep "Failed password\|Invalid user" /var/log/auth.log /var/log/secure 2>/dev/nu                                                                                       ll | tail -500 > "$OUTDIR/auth_failed.txt"
grep "Accepted" /var/log/auth.log /var/log/secure 2>/dev/null | grep -vE "$OFFIC                                                                                       E_IPS" | tail -500 > "$OUTDIR/auth_accepted_external.txt"

# 5
log "5. Hidden tmp files"
ls -la /tmp 2>/dev/null | grep "^\." > "$OUTDIR/tmp_hidden.txt" || true
ls -la /dev/shm 2>/dev/null | grep "^\." > "$OUTDIR/devshm_hidden.txt" || true
ls -la /var/tmp 2>/dev/null | grep "^\." > "$OUTDIR/vartmp_hidden.txt" || true
timeout 30 find /tmp /var/tmp /dev/shm -type f -mtime -7 -ls 2>/dev/null > "$OUT                                                                                       DIR/tmp_recent_files.txt"

# 6
log "6. File/strings tmp"
> "$OUTDIR/tmp_file_strings.txt"
find /tmp /dev/shm /var/tmp -type f -mtime -3 2>/dev/null | head -20 | while rea                                                                                       d f; do
    echo "=== $f ===" >> "$OUTDIR/tmp_file_strings.txt"
    file "$f" >> "$OUTDIR/tmp_file_strings.txt" 2>/dev/null
    strings "$f" | head -50 >> "$OUTDIR/tmp_file_strings.txt" 2>/dev/null
done

# 7
log "7. Persistence"
> "$OUTDIR/cron_all.txt"
cut -f1 -d: /etc/passwd | while read u; do echo "--- $u ---" >> "$OUTDIR/cron_al                                                                                       l.txt"; crontab -u $u -l 2>/dev/null >> "$OUTDIR/cron_all.txt"; done
ls -la /etc/cron.d /etc/cron.*ly /etc/rc.local 2>/dev/null > "$OUTDIR/cron_rc_di                                                                                       rs.txt"
timeout 10 systemctl list-timers --all > "$OUTDIR/systemctl_timers.txt" 2>/dev/n                                                                                       ull || echo "timeout" >> "$LOG"

# 8
log "8. Users"
getent passwd > "$OUTDIR/passwd.txt"
awk -F: '$3>=1000 {print $1,$3,$6}' /etc/passwd > "$OUTDIR/users_non_system.txt"

# 9
log "9. Modified files"
timeout 60 find /etc /bin /sbin /usr/bin /usr/sbin -xdev -type f -mtime -7 2>/de                                                                                       v/null > "$OUTDIR/files_modified_7d.txt"

# 10
log "10. Procs from tmp"
if command -v lsof >/dev/null 2>&1; then
    timeout 15 lsof +D /tmp +D /dev/shm +D /var/tmp 2>/dev/null > "$OUTDIR/procs                                                                                       _from_tmp.txt" || true
else
    ps aux | awk '$11 ~ /^\/tmp\/|^\/dev\/shm\/|^\/var\/tmp\// {print}' > "$OUTD                                                                                       IR/procs_from_tmp.txt"
fi

# 11
log "11. Known malware"
ps aux | grep -Ei 'xmrig|kdevtmpfsi|kinsing|ddos|watchdog|pwnrig' | grep -v grep                                                                                        > "$OUTDIR/known_malware_procs.txt" || true

# 12
log "12. SSH keys"
find /root /home -type f -name "authorized_keys" -exec sh -c 'echo FILE:$1; cat                                                                                        $1' sh {} \; 2>/dev/null > "$OUTDIR/authorized_keys_all.txt"

# 13
log "13. Fail2Ban"
if command -v fail2ban-client >/dev/null 2>&1; then
    timeout 2 fail2ban-client status sshd > "$OUTDIR/fail2ban.txt" 2>/dev/null |                                                                                       | echo "fail2ban timeout" > "$OUTDIR/fail2ban.txt"
else
    echo "fail2ban not installed" > "$OUTDIR/fail2ban.txt"
fi

# 14. ROOTKIT CHECK - FIXED
log "14. Rootkit check"

# chkrootkit
if command -v chkrootkit >/dev/null 2>&1; then
    log "Running chkrootkit, this takes ~1 min"
    timeout 120 chkrootkit > "$OUTDIR/chkrootkit.txt" 2>&1
else
    echo "chkrootkit not installed" > "$OUTDIR/chkrootkit.txt"
fi

# rkhunter
if command -v rkhunter >/dev/null 2>&1; then
    log "Running rkhunter, this takes ~2 min"
    timeout 180 rkhunter --check --sk --rwo > "$OUTDIR/rkhunter.txt" 2>&1
    echo "Exit code: $?" >> "$OUTDIR/rkhunter.txt"
else
    echo "rkhunter not installed" > "$OUTDIR/rkhunter.txt"
fi

# 15
log "15. Kernel modules"
lsmod > "$OUTDIR/lsmod.txt"

# 16
log "16. SUID"
timeout 60 find / -xdev -perm -4000 -type f 2>/dev/null > "$OUTDIR/suid_files.tx                                                                                       t"

# 17
log "17. World writable"
timeout 60 find /etc /bin /sbin /usr/bin /usr/sbin -xdev -type f -perm -002 2>/d                                                                                       ev/null > "$OUTDIR/world_writable.txt"

# 18
log "18. LD_PRELOAD"
grep -r LD_PRELOAD /etc/environment /etc/ld.so.preload 2>/dev/null > "$OUTDIR/ld                                                                                       _preload.txt" || true

# 19 - FIXED THE BROKEN QUOTE HERE
log "19. Suspicious proc details"
> "$OUTDIR/suspicious_proc_details.txt"
ps aux | awk '$11 ~ /tmp|shm/ {print $2}' | head -10 | while read pid; do
    [ -z "$pid" ] && continue
    echo "=== PID:$pid ===" >> "$OUTDIR/suspicious_proc_details.txt"
    cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' >> "$OUTDIR/suspicious_proc                                                                                       _details.txt"
    echo "" >> "$OUTDIR/suspicious_proc_details.txt"
done

# 20
log "20. Hashes"
timeout 60 find /bin /sbin /usr/bin /usr/sbin -type f -exec sha256sum {} \; 2>/d                                                                                       ev/null > "$OUTDIR/bin_hashes.txt"

log "=========================================="
log "[+] DONE. $OUTDIR"
log "Package: tar czf /root/triage.tgz $OUTDIR"

