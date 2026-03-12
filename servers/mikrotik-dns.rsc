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
add address=127.0.10.1 type=A regexp="(analytic|telemetry|beacon|tracking|trafficmanager|nexusrules|pagead)"
add address=127.0.10.1 type=A regexp="ad(serv|vert|mob|zerk|nxs|colony|cloud|corp|tube|smin|sports|snet|stat|pooh|system|-instantpage)"
add address=127.0.10.1 type=A regexp="(bing|mail-|search|image|moat|flux|inmat|adamo|adlo|pop)ads"
add address=127.0.10.1 type=A regexp="google(ad|tag|syndication|-analytic)"
add address=127.0.10.1 type=A regexp="(doubleclick|2mdn)"
add address=127.0.10.1 type=A regexp="pixel\\."
add address=127.0.10.1 type=A regexp="(fastclick|smaato|quantserver|inmobi|booru|byteoversea)"
add address=127.0.10.1 type=A regexp="^banner([s0-9]+\\.)"
add address=127.0.10.1 type=A regexp="[0-9]chan"
#add address=127.0.10.1 type=A regexp=overture
add address=127.0.10.1 type=A regexp="1\\.yimg"
add address=127.0.10.1 type=A regexp="dit\\.whatsapp"
add address=127.0.10.1 type=A regexp="static\\.ak\\.fbcdn\\.net"

#adult,gambling
add address=127.0.10.1 type=A regexp="(adult|xxx|sex|porn|playboy|friendfinder|eroti)"
add address=127.0.10.1 type=A regexp="\\.(bid|bet)"
add address=127.0.10.1 type=A regexp="(casino|kasino|poker|judol|xtube|xflix|xbet|xslot|xslut|jackpot|blackjack|gambl)"
#add address=127.0.10.1 regexp=bett type=A disabled=yes
#add address=127.0.10.1 regexp="bet[st0-9]" type=A disabled=yes
#add address=127.0.10.1 regexp=bingo type=A disabled=yes
#add address=127.0.10.1 regexp=judi type=A disabled=yes

#resources suckers
add address=127.0.10.1 type=A regexp="(tiktokv|tiktokcdn|ttwstatic|ttdns)"
add address=127.0.10.1 type=A regexp="(scdn|spotifycdn|spotify-com|spotify.map)"
add address=127.0.10.1 type=A regexp="(flix|nflx)"
add address=127.0.10.1 type=A regexp="(coin|koin)"
#add address=127.0.10.1 regexp=convert type=A
add address=127.0.10.1 regexp=steam type=A
#phishing
add address=127.0.10.1 type=A regexp="(bca-fash|bcaflash)"

#windows telemetry
add address=127.0.10.1 type=A regexp="data.(msn|microsoft)"
add address=127.0.10.1 type=A regexp="(measure|diagnostics).office"
add address=127.0.10.1 type=A regexp="(data|track.mp).microsoft"
add address=127.0.10.1 type=A regexp="(activity|blob.core).windows"
add address=127.0.10.1 type=A regexp="(applicationinsights|inference-app-gateway|azurewatson|zmetrics|diagnostics-eudb)"
add address=127.0.10.1 type=A regexp="(events.data|collector.azure|.msn.com)"

#extreme blocking
add address=127.0.10.1 disabled=yes type=A comment=allgame regexp="(play|gamer|games|gaming|arcad|arkad)"
#add address=127.0.10.1 disabled=yes regexp=ads type=A comment=allads
add address=127.0.10.1 disabled=yes regexp=adv type=A comment=alladv
dd address=127.0.10.1 disabled=yes regexp=tube type=A comment=alltube
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
