rem set secdns=https://doh-ch.blahdns.com/dns-query
set secdns=https://doh.tiarap.org/dns-query
reg.exe add "HKLM\Software\Policies\Google\Chrome" /v "DnsOverHttpsMode" /f /t REG_SZ /d "automatic"
reg.exe add "HKLM\Software\Policies\Google\Chrome" /v "DnsOverHttpsTemplates" /f /t REG_SZ /d "%secdns%"

reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BuiltInDnsClientEnabled" /f /t REG_DWORD /d "1"
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DnsOverHttpsMode" /f /t REG_SZ /d "automatic"
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DnsOverHttpsTemplates" /f /t REG_SZ /d "%secdns%"

