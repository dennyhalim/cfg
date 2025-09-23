#new
saveTo=/var/www/html/bl
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/dshield_7d.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=6d23:59:59 comment=dshield.bl.dennyhalim.com } on-error={}";}' > $saveTo/dshield_7d.rsc
#careful fh1 might block too much local networks
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/firehol_level1.netset | grep -v  "127.0.0.0\|192.168.0.0\|172.16.0.0\|10.0.0.0\|100.64.0.0\|0.0.0.0" | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=6d23:59:57 comment=fh1.bl.dennyhalim.com } on-error={}";}' > $saveTo/fh1.rsc
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/et_block.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:58 comment=et.bl.dennyhalim.com } on-error={}";}' > $saveTo/et_block.rsc
#wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/firehol_webserver.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 comment=fhweb.bl.dennyhalim.com } on-error={}";}' > $saveTo/fhweb.rsc
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/stopforumspam_toxic.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=6d23:59:59 comment=toxic.bl.dennyhalim.com } on-error={}";}' > $saveTo/toxic.rsc
#iblocklist hijacked
#wget -q -O - "http://list.iblocklist.com/?list=usrcshglbiilevmyfhse&fileformat=cidr&archiveformat=gz" | zcat | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 comment=hijack.bl.dennyhalim.com } on-error={}";}' > $saveTo/iblocklist-hijacked.rsc

cd $saveTo
cat dshield_7d.rsc toxic.rsc et_block.rsc > combined1.rsc
cat dshield_7d.rsc toxic.rsc fh1.rsc > combined2.rsc
cat dshield_7d.rsc toxic.rsc fh1.rsc iblocklist-hijacked.rsc et_block.rsc > combined-all.rsc
wc -l $saveTo/*
