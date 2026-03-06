w32tm.exe /config /manualpeerlist:"time.nist.gov id.pool.ntp.org" /syncfromflags:all
sc.exe triggerinfo w32time start/networkon stop/networkoff
sc.exe stop w32time
sc.exe start w32time
w32tm.exe /resync /rediscover /nowait
w32tm.exe /query /status
