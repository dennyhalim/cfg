rem list doh server https://adguard-dns.io/kb/general/dns-providers/
rem set secdns=https://doh-ch.blahdns.com/dns-query
set secdns=https://doh.tiarap.org/dns-query
rem chrome settings
reg.exe add "HKLM\Software\Policies\Google\Chrome" /v "DnsOverHttpsMode" /f /t REG_SZ /d "automatic"
reg.exe add "HKLM\Software\Policies\Google\Chrome" /v "DnsOverHttpsTemplates" /f /t REG_SZ /d "%secdns%"
rem ms edge settings
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BuiltInDnsClientEnabled" /f /t REG_DWORD /d "1"
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DnsOverHttpsMode" /f /t REG_SZ /d "automatic"
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DnsOverHttpsTemplates" /f /t REG_SZ /d "%secdns%"
rem firefox settings
reg add "HKLM\Software\Policies\Mozilla\Firefox\DNSOverHTTPS" /v "ProviderURL" /f /t REG_SZ /d "%secdns%"
rem reg add "HKLM\Software\Policies\Mozilla\Firefox\DNSOverHTTPS" /v "Enabled" /f /t REG_DWORD /d "1"
rem reg add "HKLM\Software\Policies\Mozilla\Firefox\DNSOverHTTPS" /v "Locked" /f /t REG_DWORD /d "1"
rem reg add "HKLM\Software\Policies\Mozilla\Firefox\DNSOverHTTPS" /v "ExcludedDomains" /f /t REG_SZ /d "example.com"

