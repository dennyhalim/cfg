#new
saveTo=/var/www/html/bl
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/dshield_7d.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=6d comment=bl.dennyhalim.com } on-error={}";}' >> $saveTo/dshield.rsc
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/et_block.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 comment=bl.dennyhalim.com } on-error={}";}' >> $saveTo/etblock.rsc
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/firehol_webserver.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 comment=bl.dennyhalim.com } on-error={}";}' >> $saveTo/fhweb.rsc
#iblocklist hijacked
#wget -q -O - "http://list.iblocklist.com/?list=usrcshglbiilevmyfhse&fileformat=cidr&archiveformat=gz" | zcat | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 } on-error={}";}' >> $saveTo/iblocklist-hijacked.rsc
