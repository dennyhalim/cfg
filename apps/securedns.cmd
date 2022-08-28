set secdns=https://doh-ch.blahdns.com/dns-query
reg.exe add "HKLM\Software\Policies\Google\Chrome" /v DnsOverHttpsMode /f /t REG_SZ /d "automatic"
reg.exe add "HKLM\Software\Policies\Google\Chrome" /v DnsOverHttpsTemplates /f /t REG_SZ /d %secdns%
