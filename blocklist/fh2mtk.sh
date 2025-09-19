#new
saveTo=/var/www/html/bl/firehol.rsc
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/dshield_7d.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=6d } on-error={}";}' >> $saveTo
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/et_block.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 } on-error={}";}' >> $saveTo
wget -q -O - https://raw.githubusercontent.com/firehol/blocklist-ipsets/refs/heads/master/firehol_webserver.netset | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "do { /ip firewall address-list add address=" $1 " list=daftarblokir timeout=23:59:59 } on-error={}";}' >> $saveTo
