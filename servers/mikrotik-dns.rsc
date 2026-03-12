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
add address=127.0.10.1 type=A regexp=adserv
add address=127.0.10.1 type=A regexp=advert
add address=127.0.10.1 type=A regexp=analytic
add address=127.0.10.1 type=A regexp=telemetry
add address=127.0.10.1 type=A regexp=beacon
add address=127.0.10.1 type=A regexp=tracking
add address=127.0.10.1 type=A regexp=pixel disabled=yes
add address=127.0.10.1 type=A regexp=googletag
add address=127.0.10.1 type=A regexp=googlead
add address=127.0.10.1 type=A regexp=googlesyndication
add address=127.0.10.1 type=A regexp=mail-ads
add address=127.0.10.1 type=A regexp=searchads
add address=127.0.10.1 type=A regexp=pagead
add address=127.0.10.1 type=A regexp=imageads
add address=127.0.10.1 type=A regexp=doubleclick
add address=127.0.10.1 type=A regexp=2mdn
add address=127.0.10.1 type=A regexp="\\.msn\\.com"
add address=127.0.10.1 type=A regexp=bingads
add address=127.0.10.1 type=A regexp="events\\.data"
add address=127.0.10.1 type=A regexp=ad-instantpage
add address=127.0.10.1 type=A regexp=nexusrules
add address=127.0.10.1 type=A regexp=trafficmanager
add address=127.0.10.1 type=A regexp=admob
add address=127.0.10.1 type=A regexp=adnxs
add address=127.0.10.1 type=A regexp=adzerk
add address=127.0.10.1 type=A regexp=moatads
add address=127.0.10.1 type=A regexp=fastclick
add address=127.0.10.1 type=A regexp=smaato
add address=127.0.10.1 type=A regexp=banners
add address=127.0.10.1 type=A regexp="^banner([0-9]+\\.)"
add address=127.0.10.1 type=A regexp=fluxads
add address=127.0.10.1 type=A regexp=inmatads
add address=127.0.10.1 type=A regexp=adamoads
add address=127.0.10.1 type=A regexp=adloads
add address=127.0.10.1 type=A regexp=adcolony
add address=127.0.10.1 type=A regexp=adcloud
add address=127.0.10.1 type=A regexp=adcorp
add address=127.0.10.1 type=A regexp=adtube
add address=127.0.10.1 type=A regexp=adsmin
add address=127.0.10.1 type=A regexp=adsports
add address=127.0.10.1 type=A regexp=adsnet
add address=127.0.10.1 type=A regexp=adstat
add address=127.0.10.1 type=A regexp=popads
add address=127.0.10.1 type=A regexp=adpooh
add address=127.0.10.1 type=A regexp=booru
add address=127.0.10.1 type=A regexp="[0-9]chan"
add address=127.0.10.1 type=A regexp=amazon-adsystem
add address=127.0.10.1 type=A regexp=overture
add address=127.0.10.1 type=A regexp=quantserve
add address=127.0.10.1 type=A regexp=inmobi
add address=127.0.10.1 type=A regexp=1.yimg
add address=127.0.10.1 type=A regexp=dit.whatsapp
add address=127.0.10.1 type=A regexp=static.ak.fbcdn.net

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
add address=127.0.10.1 regexp=judol type=A
add address=127.0.10.1 regexp=xbet type=A
add address=127.0.10.1 regexp=xslot type=A
add address=127.0.10.1 regexp=jackpot type=A
add address=127.0.10.1 regexp=bett type=A
add address=127.0.10.1 regexp="bet[st0-9]" type=A disabled=yes
add address=127.0.10.1 regexp=slut type=A disabled=yes
add address=127.0.10.1 regexp=slot type=A disabled=yes
add address=127.0.10.1 regexp=bingo type=A disabled=yes
add address=127.0.10.1 regexp=judi type=A disabled=yes

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
