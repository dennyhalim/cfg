rem netsh interface show interface
rem https://cleanbrowsing.org/ip-address
rem https://www.quad9.net/microsoft/
rem wmic nicconfig where (IPEnabled=TRUE) call SetDNSServerSearchOrder ("185.228.168.10", "9.9.9.9")
netsh interface ipv4 add dnsserver "Wi-Fi" address=185.228.168.10 index=1
netsh interface ipv4 add dnsserver "Wi-Fi" address=9.9.9.9 index=2
netsh interface ipv6 add dnsserver "Wi-Fi" address=2a0d:2a00:1::1 index=1
netsh interface ipv6 add dnsserver "Wi-Fi" address=2620:fe::fe index=2
