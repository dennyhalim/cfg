# dennyhalim.com
# mikrotik dns blocking 
# warning: test to see if it fits your need

/ip dns static
#blocking wpad
add address=127.0.0.0 regexp="^wpad\\." type=A
#safesearch
add cname=strict.bing.com name=www.bing.com type=CNAME
add address=216.239.38.119 regexp=www.google.co type=A

#super blokcer ads & tracking
add address=127.0.10.1 regexp=banner type=A disabled=yes
add address=127.0.10.1 regexp=banners type=A
add address=127.0.10.1 regexp=googletag type=A
add address=127.0.10.1 regexp=googlead type=A
add address=127.0.10.1 regexp=googlesyndication type=A
add address=127.0.10.1 regexp=doubleclick type=A
add address=127.0.10.1 regexp=adserv type=A
add address=127.0.10.1 regexp=advert type=A
add address=127.0.10.1 regexp=admob type=A
add address=127.0.10.1 regexp=adnxs type=A
add address=127.0.10.1 regexp=adzerk type=A
add address=127.0.10.1 regexp=moatads type=A
add address=127.0.10.1 regexp=fastclick type=A
add address=127.0.10.1 regexp=smaato type=A
add address=127.0.10.1 regexp=2mdn type=A
add address=127.0.10.1 regexp=analytic type=A
add address=127.0.10.1 regexp=telemetry type=A
add address=127.0.10.1 regexp=nexusrules type=A
add address=127.0.10.1 regexp=beacons type=A
add address=127.0.10.1 regexp=tracking type=A
add address=127.0.10.1 regexp=trafficmanager type=A
add address=127.0.10.1 regexp=dit.whatsapp type=A
add address=127.0.10.1 regexp=fluxads type=A
add address=127.0.10.1 regexp=inmatads type=A
add address=127.0.10.1 regexp=adamoads type=A
add address=127.0.10.1 regexp=adloads type=A
add address=127.0.10.1 regexp=adcolony type=A
add address=127.0.10.1 regexp=adcloud type=A
add address=127.0.10.1 regexp=adcorp type=A
add address=127.0.10.1 regexp=adtube type=A
add address=127.0.10.1 regexp=adsmin type=A
add address=127.0.10.1 regexp=adsports type=A
add address=127.0.10.1 regexp=adsnet type=A
add address=127.0.10.1 regexp=adstat type=A
add address=127.0.10.1 regexp=popads type=A

#adult,gambling
add address=127.0.10.1 regexp=adult type=A
add address=127.0.10.1 regexp=xxx type=A
add address=127.0.10.1 regexp=sex type=A
add address=127.0.10.1 regexp=porn type=A
add address=127.0.10.1 regexp=playboy type=A
add address=127.0.10.1 regexp=friendfinder type=A
add address=127.0.10.1 regexp="\\.bid" type=A
add address=127.0.10.1 regexp=casino type=A
add address=127.0.10.1 regexp=kasino type=A
add address=127.0.10.1 regexp=gambl type=A
add address=127.0.10.1 regexp=poker type=A
add address=127.0.10.1 regexp=judi type=A
add address=127.0.10.1 regexp=judol type=A
add address=127.0.10.1 regexp=xbet type=A
add address=127.0.10.1 regexp=xslot type=A
add address=127.0.10.1 regexp=bett type=A
add address=127.0.10.1 regexp=bett type=A
add address=127.0.10.1 regexp=bet type=A disabled=yes
add address=127.0.10.1 regexp=slot type=A disabled=yes

#windows telemetry
add address=127.0.10.1 regexp=applicationinsights type=A
add address=127.0.10.1 regexp=collector.azure type=A
add address=127.0.10.1 regexp=data.msn type=A
add address=127.0.10.1 regexp=inference-app-gateway type=A
add address=127.0.10.1 regexp=measure.office.net type=A
add address=127.0.10.1 regexp=data.microsoft type=A
add address=127.0.10.1 regexp=azurewatson type=A
add address=127.0.10.1 regexp=inference-app-gateway type=A
add address=127.0.10.1 regexp=track.mp.microsoft type=A
add address=127.0.10.1 regexp=diagnostics.office type=A
add address=127.0.10.1 regexp=measure.office type=A
add address=127.0.10.1 regexp=activity.windows type=A
add address=127.0.10.1 regexp=zmetrics type=A
add address=127.0.10.1 regexp=diagnostics-eudb type=A
add address=127.0.10.1 regexp=blob.core.windows type=A

#resources suckers
add address=127.0.10.1 regexp=byteoversea type=A
add address=127.0.10.1 regexp=ttdns type=A
add address=127.0.10.1 regexp=tiktokv type=A
add address=127.0.10.1 regexp=tiktokcdn type=A
add address=127.0.10.1 regexp=ttwstatic type=A
add address=127.0.10.1 regexp=flix type=A
add address=127.0.10.1 regexp=nflx type=A
add address=127.0.10.1 regexp=coin type=A
add address=127.0.10.1 regexp=koin type=A
#add address=127.0.10.1 regexp=convert type=A
add address=127.0.10.1 regexp=steam type=A
#phishing
add address=127.0.10.1 regexp=bca-fash type=A
add address=127.0.10.1 regexp=bcaflash type=A

#extreme blocking
add address=127.0.10.1 disabled=yes regexp=game type=A comment=allgame
add address=127.0.10.1 disabled=yes regexp=gaming type=A comment=allgame
add address=127.0.10.1 disabled=yes regexp=arcad type=A comment=allgame
add address=127.0.10.1 disabled=yes regexp=arkad type=A comment=allgame
add address=127.0.10.1 disabled=yes regexp=ads type=A comment=allads
add address=127.0.10.1 disabled=yes regexp=adv type=A comment=alladv
add address=127.0.10.1 disabled=yes regexp=tube type=A comment=alltube
add address=127.0.10.1 disabled=yes regexp=cdninstagram type=A comment=ig
add address=127.0.10.1 disabled=yes regexp=connect.facebook type=A comment=fb
add address=127.0.10.1 disabled=yes regexp=fbcdn type=A comment=fb
add address=127.0.10.1 disabled=yes regexp=meta type=A comment=fb
add address=127.0.10.1 disabled=yes regexp=fbjs type=A comment=fb
add address=127.0.10.1 disabled=yes regexp=fbsbx type=A comment=fb
add address=127.0.10.1 disabled=yes regexp=tfbnw type=A comment=fb
add address=127.0.10.1 disabled=yes regexp=msn type=A comment=ms
add address=127.0.10.1 disabled=yes regexp=bola type=A comment=allsport
add address=127.0.10.1 disabled=yes regexp=sport type=A comment=allsport
add address=127.0.10.1 disabled=yes regexp=video type=A comment=allvideo
add address=127.0.10.1 disabled=yes regexp=audio type=A comment=allaudio
add address=127.0.10.1 disabled=yes regexp=radio type=A comment=allradio
add address=127.0.10.1 disabled=yes regexp=stream type=A comment=allstreaming
add address=127.0.10.1 disabled=yes regexp=akamaihd type=A comment=extreme
