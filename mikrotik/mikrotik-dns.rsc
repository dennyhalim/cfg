# dennyhalim.com
# mikrotik dns blocking 
# warning: test to see if it fits your need

/ip dns static
#blocking wpad
add address=127.0.0.0 regexp="^wpad\\." type=A
#safesearch
add cname=strict.bing.com name=www.bing.com type=CNAME
add address=216.239.38.119 regexp=www.google.co type=A

#super blocker ads & tracking
#mikrotik do not support too long regexp
add address=127.0.10.1 type=A regexp="google(ad|tag|syndication|-analytic)"
add address=127.0.10.1 type=A regexp="ad(serv|vert|mob|zerk|nxs|system|tube)"
add address=127.0.10.1 type=A regexp="(bing|mail-|search|image|video|samsung|tv)ads"
add address=127.0.10.1 type=A regexp="(doubleclick|2mdn|pagead|quantserve|booru|byteoversea|heytapmobi)"
add address=127.0.10.1 type=A regexp="(analyti|telemetry|beacon|tracking|trafficmanager|nexusrules|piwik)"
add address=127.0.10.1 type=A regexp="(adult|lgbt|xxx|porn|sex|webcam|casino|poker)"
add address=127.0.10.1 type=A regexp="\\.(top|cfd|icu|gq|tk|bet|bid)"

add address=127.0.10.1 type=A regexp="ads(flame|keeper|ports|2live|tat|min|co)"
add address=127.0.10.1 type=A regexp="ad-(instantpage|connect)"
add address=127.0.10.1 type=A regexp="ad(snet|colony|cloud|corp|nami|nz|yboh)"
add address=127.0.10.1 type=A regexp="ad(viad|verge|incube|just|recover|tekmedia|pooh)"
add address=127.0.10.1 type=A regexp="(game|moat|flux|inmat|adamo|adlo|insur)ads"
add address=127.0.10.1 type=A regexp="(maticoo|revenu|pimp|purple|pop|euro|begin)ads"
add address=127.0.10.1 type=A regexp="(fastclick|smaato|inmobi)"
add address=127.0.10.1 type=A regexp="(tracker|comscore|scorecardresearch|metric|counter|openx)"
add address=127.0.10.1 type=A regexp="(appdynamic|appnexus|ekomi|grapeshot|nanovisor)"
add address=127.0.10.1 type=A regexp="^pixel\\."
add address=127.0.10.1 type=A regexp="1\\.yimg"
add address=127.0.10.1 type=A regexp="dit\\.whatsapp"
add address=127.0.10.1 type=A regexp="static\\.ak\\.fbcdn\\.net"
#down here might cause more false positives for ads
add address=127.0.10.1 type=A regexp="^(ad|ads|adv|banner|banners|track|count|mkt)([0-9]+[-\\.])"
add address=127.0.10.1 type=A regexp="[0-9]chan"
#add address=127.0.10.1 type=A regexp=overture

#adult,gambling,drugs
add address=127.0.10.1 type=A regexp="(xnxx|sadis|playboy|dewasa|bokep|hentai|friendfinder)"
add address=127.0.10.1 type=A regexp="(naked|nude|erect|escort|eroti)"
add address=127.0.10.1 type=A regexp="\\.(bid|bet|casino|poker|bingo|slots|games|gambling)"
add address=127.0.10.1 type=A regexp="\\.(adult|lgbt|xxx|porn|sex|sexy|webcam|cam|gay|tube)"
add address=127.0.10.1 type=A regexp="(casino|kasino|poker|lotter|gambl|xtube|xflix|xbet)"
add address=127.0.10.1 type=A regexp="(xslot|xslut|jackpot|blackjack|judol|taruhan|togel)"
add address=127.0.10.1 type=A regexp="(addict|vape|vapor|vaping|weightloss|cialis|viagra|pill)"
#add address=127.0.10.1 regexp="bet[st0-9]" type=A disabled=yes
#add address=127.0.10.1 type=A disabled=yes regexp="(bingo|judi|bett)"
#pagan
add address=127.0.10.1 type=A regexp="(yoga|taichi|qigong|reiki|buddh|rosar|ruqyah)"
add address=127.0.10.1 type=A regexp="(spiritual|newage|lectio|divina|halloween|mindfulness)"
add address=127.0.10.1 type=A regexp="(exorcis|occult|magics|newage)"

#resources suckers
add address=127.0.10.1 type=A regexp="(tiktokv|tiktokw|tiktokcdn|ttwstatic|ttdns|bytedns)"
add address=127.0.10.1 type=A regexp="(musical.ly|bytedance|toutiau|pstatp|capcutapi|snssdk)"
add address=127.0.10.1 type=A regexp="(flix|nflx|scdn|spotifycdn|spotify-com|spotify.map)"
add address=127.0.10.1 type=A regexp="(coin|koin|crypto|kripto)"
#add address=127.0.10.1 regexp=convert type=A
#phishing 
add address=127.0.10.1 type=A regexp="bca(-fash|flash)"
add address=127.0.10.1 type=A regexp="(login|clone)*\\.(vercel|netlify|blogspot|webflow|webly)"
add address=127.0.10.1 type=A regexp="(facebook|instagram|netflix|amazon)*\\.(vercel|netlify|blogspot|webflow|webly)"
#games
add address=127.0.10.1 disabled=yes type=A comment=allgame regexp="(gamer|games|gaming|arcad|arkad|steam)"

#windows telemetry
add address=127.0.10.1 type=A regexp="data.(msn|microsoft)"
add address=127.0.10.1 type=A regexp="(data|track.mp).microsoft"
add address=127.0.10.1 type=A regexp="(activity|blob.core).windows"
add address=127.0.10.1 type=A regexp="(measure|diagnostics).office"
add address=127.0.10.1 type=A regexp="(events.data|collector.azure|.msn.com)"
add address=127.0.10.1 type=A regexp="(applicationinsights|inference-app-gateway|azurewatson|zmetrics|diagnostics-eudb)"

#extreme blocking WILL certainly cause lots of false positives
add address=127.0.10.1 disabled=yes type=A regexp="(click|cheap|free|deal|bargain|profit|rich)"
add address=127.0.10.1 disabled=yes type=A regexp="(drug|pharm|tablet|diet|meds|medic|rx|xx)"
add address=127.0.10.1 disabled=yes type=A regexp="(stream|audio|video|radio|tube|akamaihd)"
add address=127.0.10.1 disabled=yes type=A regexp="(bola|skor|sport|goal)"
add address=127.0.10.1 disabled=yes type=A regexp="(meta|fbcdn|fbjs|fbsbx|tfbnw|connect.facebook|cdninstagram)"
#add address=127.0.10.1 disabled=yes type=A comment=allads regexp=(track|stat|count|banner|adv|ads|ad[0-9])
add address=127.0.10.1 disabled=yes type=A comment=CDNcrazyblocker regexp="(cdn|akamai|akadns|fastly|edgesuite|cloudflare|cloudfront|edgecast)"

