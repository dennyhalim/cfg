set secdns=https://doh-ch.blahdns.com/dns-query
reg.exe add "HKLM\Software\Policies\Google\Chrome" /v DnsOverHttpsMode /f /t REG_SZ /d "automatic" /f
reg.exe add "HKLM\Software\Policies\Google\Chrome" /v DnsOverHttpsTemplates /f /t REG_SZ /d "%secdns%" /f

reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BuiltInDnsClientEnabled" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DnsOverHttpsMode " /t REG_SZ /d "automatic" /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DnsOverHttpsTemplates" /t REG_SZ /d "%secdns%" /f

