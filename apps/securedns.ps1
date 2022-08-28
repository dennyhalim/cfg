# list doh server https://adguard-dns.io/kb/general/dns-providers/
# set secdns=https://doh-ch.blahdns.com/dns-query
$secdns="https://doh.tiarap.org/dns-query"
# chrome settings
#reg.exe add "HKLM\Software\Policies\Google\Chrome" /v "DnsOverHttpsMode" /f /t REG_SZ /d "automatic"
reg.exe add "HKLM\Software\Policies\Google\Chrome" /v "DnsOverHttpsTemplates" /f /t REG_SZ /d "$secdns"
# ms edge settings
#reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BuiltInDnsClientEnabled" /f /t REG_DWORD /d "1"
#reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DnsOverHttpsMode" /f /t REG_SZ /d "automatic"
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DnsOverHttpsTemplates" /f /t REG_SZ /d "$secdns"
# firefox settings
# reg add "HKLM\Software\Policies\Mozilla\Firefox\DNSOverHTTPS" /v "Enabled" /f /t REG_DWORD /d "1"
# reg add "HKLM\Software\Policies\Mozilla\Firefox\DNSOverHTTPS" /v "Locked" /f /t REG_DWORD /d "1"
# reg add "HKLM\Software\Policies\Mozilla\Firefox\DNSOverHTTPS" /v "ExcludedDomains" /f /t REG_SZ /d "example.com"
reg add "HKLM\Software\Policies\Mozilla\Firefox\DNSOverHTTPS" /v "ProviderURL" /f /t REG_SZ /d "$secdns"

#windows
#netsh dns add encryption server=174.138.21.128 dohtemplate=$secdns autoupgrade=yes udpfallback=yes
Add-DnsClientDohServerAddress -ServerAddress 174.138.21.128 -DohTemplate $secdns -AllowFallbackToUdp $True -AutoUpgrade $True 
