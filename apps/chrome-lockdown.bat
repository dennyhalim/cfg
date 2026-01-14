Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome" /v DnsOverHttpsMode /t reg_sz /d secure /f
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome" /v DnsOverHttpsTemplates /t reg_sz /d "https://all.dns.mullvad.net/dns-query" /f
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome\ClearBrowsingDataOnExitList" /v 1 /t reg_sz /d "cached_images_and_files" /f
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome" /v BackgroundModeEnabled /t reg_dword /d 0 /f
rem Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionSettings" /v * /t reg_sz /d '{\"blocked_permissions\":[\"debugger\",\"history\",\"tabs\",\"sessions\",\"privacy\",\"management\",\"downloads\",\"serial\",\"vpnProvider\",\"proxy\",\"experimental\"]}' /f
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist" /v 1 /t reg_sz /d * /f
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" /v 1 /t reg_sz /d mlomiejdfkolichcflejclcbmpeaniij /f
Reg.exe Add "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" /v 1 /t reg_sz /d oboonakemofpalcgghocfoadofidjkkk /f
