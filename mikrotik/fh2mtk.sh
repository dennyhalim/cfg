#new
saveTo=/var/www/my_webapp/www/blocklists
cd $saveTo
rm -f *.netset *.ipv4
wget "https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/dshield_7d.netset"
wget "https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/firehol_level1.netset"
wget "https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/et_block.netset"
wget "https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/stopforumspam_toxic.netset"
wget "https://raw.githubusercontent.com/borestad/blocklist-abuseipdb/refs/heads/main/stats/hallofshame/subnets/abuseipdb-s99-hallofshame-7d-75percent.ipv4"
wget -q -O - "http://list.iblocklist.com/?list=usrcshglbiilevmyfhse&fileformat=cidr&archiveformat=gz" | zcat > iblocklist-hijacked.netset

cat dshield_7d.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=6d23:59:59 comment=dshield.bl.dennyhalim.com } on-error={}";}' > $saveTo/mikrotik/dshield.rsc
cat firehol_level1.netset | grep -v  "127.0.0.0\|192.168.0.0\|172.16.0.0\|10.0.0.0\|100.64.0.0\|0.0.0.0" | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 comment=fh1.bl.dennyhalim.com } on-error={}";}' > $saveTo/mikrotik/fh1.rsc
cat et_block.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 comment=et.bl.dennyhalim.com } on-error={}";}' > $saveTo/mikrotik/etblock.rsc
cat stopforumspam_toxic.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=6d23:59:59 comment=toxic.bl.dennyhalim.com } on-error={}";}' > $saveTo/mikrotik/toxic.rsc
cat abuseipdb-s99-hallofshame-7d-75percent.ipv4 | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=6d23:59:59 comment=toxic.bl.dennyhalim.com } on-error={}";}' > $saveTo/mikrotik/abuseipdb.rsc
#iblocklist hijacked
cat iblocklist-hijacked.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 comment=hijack.bl.dennyhalim.com } on-error={}";}' > $saveTo/mikrotik/iblocklist-hijacked.rsc

cd mikrotik
cat dshield.rsc toxic.rsc etblock.rsc abuseipdb.rsc > combined1.rsc
cat dshield.rsc toxic.rsc fh1.rsc abuseipdb.rsc > combined2.rsc
cat dshield.rsc toxic.rsc fh1.rsc iblocklist-hijacked.rsc etblock.rsc abuseipdb.rsc > combined-all.rsc
wc -l *
