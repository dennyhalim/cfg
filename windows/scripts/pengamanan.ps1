reagentc.exe /enable
Checkpoint-Computer windowsconfig

sc.exe config wsearch start= demand
sc.exe config wuauserv start= demand
sc.exe config netbt start= disabled
sc.exe config termservice start= disabled
sc.exe config lanmanserver start= disabled
sc.exe config DiagTrack start= disabled
sc.exe config dmwappushservice start= disabled
sc.exe config WinHttpAutoProxySvc start= disabled
sc.exe triggerinfo w32time start/networkon stop/networkoff
sc.exe config TapiSrv start= disabled

