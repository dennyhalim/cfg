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
add address=127.0.10.1 type=A regexp="(analytic|telemetry|beacon|tracking|trafficmanager|nexusrules|comscore)"
add address=127.0.10.1 type=A regexp="ad(serv|vert|mob|zerk|nxs|colony|cloud|corp|tube|smin|sports|snet|stat|pooh|system|-instantpage)"
add address=127.0.10.1 type=A regexp="(bing|mail-|search|image|moat|flux|inmat|adamo|adlo|pop)ads"
add address=127.0.10.1 type=A regexp="google(ad|tag|syndication|-analytic)"
add address=127.0.10.1 type=A regexp="(doubleclick|2mdn|pagead|fastclick|smaato|quantserver|inmobi|booru|byteoversea)"
add address=127.0.10.1 type=A regexp="^pixel\\."
add address=127.0.10.1 type=A regexp="^(ad|banner)([sv0-9]+\\.)"
add address=127.0.10.1 type=A regexp="[0-9]chan"
#add address=127.0.10.1 type=A regexp=overture
add address=127.0.10.1 type=A regexp="1\\.yimg"
add address=127.0.10.1 type=A regexp="dit\\.whatsapp"
add address=127.0.10.1 type=A regexp="static\\.ak\\.fbcdn\\.net"

#adult,gambling
add address=127.0.10.1 type=A regexp="(adult|lgbt|xxx|porn|sex|sexy|porn|playboy|friendfinder|erect|eroti)"
add address=127.0.10.1 type=A regexp="\\.(bid|bet|adult|lgbt|xxx|porn|sex|sexy|porn|gay|webcam|cam|tube)"
add address=127.0.10.1 type=A regexp="(casino|kasino|poker|judol|xtube|xflix|xbet|xslot|xslut|jackpot|blackjack|gambl|lotter)"
add address=127.0.10.1 type=A regexp="(weightloss|cialis|viagra|pill|clickbank)"
#add address=127.0.10.1 regexp="bet[st0-9]" type=A disabled=yes
#add address=127.0.10.1 type=A disabled=yes regexp="(bingo|judi|bett)"
#pagan
add address=127.0.10.1 type=A regexp="(yoga|taichi|qigong|reiki|buddh|rosar|exorcis|spiritual|newage|lectio|divina|halloween|mindfulness|occult|magic|newage)"

#resources suckers
add address=127.0.10.1 type=A regexp="(tiktokv|tiktokw|tiktokcdn|ttwstatic|ttdns|bytedns|musical.ly|toutiau|bytedance|pstatp)"
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
add address=127.0.10.1 disabled=yes type=A regexp="(click|cheap|free|deal|bargain|profit|rich|stock|trade|option)"
add address=127.0.10.1 disabled=yes type=A regexp="(drug|pharm|tablet|diet|meds|medic|rx|xx)"
add address=127.0.10.1 disabled=yes type=A comment=allgame regexp="(play|gamer|games|gaming|arcad|arkad)"
add address=127.0.10.1 disabled=yes type=A regexp="(stream|audio|video|radio|tube|akamaihd)"
add address=127.0.10.1 disabled=yes type=A regexp="(bola|sports|goal)"
add address=127.0.10.1 disabled=yes type=A regexp="(meta|fbcdn|fbjs|fbsbx|tfbnw|connect.facebook|cdninstagram)"
#add address=127.0.10.1 disabled=yes regexp=ads type=A comment=allads
#add address=127.0.10.1 disabled=yes regexp=adv type=A comment=alladv
add address=127.0.10.1 disabled=yes type=A comment=CDNcrazyblocker regexp="(cdn|akamai|akadns|fastly|edgesuite|cloudflare|cloudfront|edgecast)"

