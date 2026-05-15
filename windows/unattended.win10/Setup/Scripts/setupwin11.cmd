Windows Registry Editor Version 5.00
;REAGENTC.EXE /enable
;bcdedit.exe /set {current} nx OptOut
;REG.EXE import "%~f0"
;net.exe accounts /minpwlen:14 /lockoutthreshold:5 /lockoutduration:15 /lockoutwindow:15
;sc.exe config tapisrv start= demand
;sc.exe config winrm start= demand
;sc.exe config netbt start= disabled
;sc.exe config termservice start= disabled
;sc.exe config lanmanserver start= disabled
;sc.exe config DiagTrack start= disabled
;sc.exe config dmwappushservice start= disabled
;rem sc.exe config WinHttpAutoProxySvc start= disabled
;rem cis1
;sc.exe config upnphost start= disabled
;sc.exe config ssdpsrv start= disabled
;sc.exe config SharedAccess start= disabled
;sc.exe config icssvc start= disabled
;sc.exe config IISADMIN start= disabled
;netsh.exe advfirewall firewall set rule name"File and Printer Sharing (Restrictive) (LLMNR-UDP-In)" new enable=no
;netsh.exe advfirewall firewall set rule group="Dropbox promotion" new enable=no
;netsh.exe advfirewall firewall set rule group="Feedback Hub" new enable=no
;netsh.exe advfirewall firewall set rule group="Network Discovery" new enable=no
;netsh.exe advfirewall firewall set rule group="Remote Assistance" new enable=no
;netsh.exe advfirewall firewall set rule group="File and Printer Sharing" new enable=no
;netsh.exe advfirewall firewall set rule group="Windows Feature Experience Pack" new enable=no
;exit
;
; !!! TEST BEFORE USED ON PRODUCTION !!! ;
; !!! I WILL NOT BE RESPONSIBLE IF YOUR COMPUTER CRASH OR EXPLODE !!! ;
; https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-update#branchreadinesslevel 
;open command prompt as administrator
;del setupwin11.cmd
;curl.exe -O https://raw.githubusercontent.com/dennyhalim/cfg/refs/heads/master/windows/unattended.win10/Setup/Scripts/setupwin11.cmd
;#edit to suite your need and run
;reg.exe import setupwin11.cmd

;windows update
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate]
"ProductVersion"="Windows 11"
"TargetReleaseVersionInfo"="24H2"
"TargetReleaseVersion"=dword:00000001
"BranchReadinessLevel"=dword:00000020
"DeferQualityUpdates"=dword:00000001
"DeferQualityUpdatesPeriodInDays"=dword:0000000b
"DeferUpgrade"=dword:00000001
"DeferUpgradePeriod"=dword:00000008
"DeferFeatureUpdates"=dword:00000001
"DeferFeatureUpdatesPeriodInDays"=dword:000000b4
"DeferUpdatePeriod"=dword:00000002
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU]
"ScheduledInstallDay"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsAI]
"AllowRecallEnablement"=dword:00000000
"DisableAIDataAnalysis"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services]
"fAllowToGetHelp"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard]
;"LsaCfgFlags"=dword:00000001

;chrome
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Update]
"RollbackToTargetVersion"=dword:00000001
"targetChannel"="extended"
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome]
"DnsOverHttpsMode"="secure"
"DnsOverHttpsTemplates"="https://all.dns.mullvad.net/dns-query"
"BackgroundModeEnabled"=dword:00000000
"QuicAllowed"=dword:00000000
"PasswordManagerEnabled"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ClearBrowsingDataOnExitList]
"901"="cached_images_and_files"
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist]
"901"="lgblnfidahcdcjddiepkckcfdhpknnjh"
"902"="jfofijpkapingknllefalncmbiienkab"
"903"="oboonakemofpalcgghocfoadofidjkkk"
[-HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionInstallAllowlist]
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionSettings]
"*"="{\"blocked_permissions\":[\"clipboardRead\",\"background\",\"sessions\",\"management\",\"vpnProvider\",\"proxy\",\"webAuthenticationProxy\",\"pageCapture\",\"tabCapture\",\"debugger\",\"experimental\"]}"

;edge
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate]
"TargetChannel"="ExtendedStable"
"RollbackToTargetVersion"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
"QuicAllowed"=dword:00000000
"ClearCachedImagesAndFilesOnExit"=dword:00000001
"HubsSidebarEnabled"=dword:00000000
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\MicrosoftEdge\Main]
"FormSuggest Passwords"="no"
#copilot
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"EnableDynamicContentInWSB"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\ExtensionSettings]
"*"="{\"blocked_permissions\":[\"clipboardRead\",\"background\",\"sessions\",\"management\",\"vpnProvider\",\"proxy\",\"webAuthenticationProxy\",\"pageCapture\",\"tabCapture\",\"debugger\",\"experimental\"]}"
;[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist]
"901"="jlpdpddffjddlfdbllimedpemaodbjgn"
"902"="pdffhmdngciaglkoonimfcmckehcpafo"
"903"="jccfboncbdccgbgcbhickioeailgpkgb"
;from chromestore "904"="hielpjjagjimpgppnopiibaefhfpbpfn;https://clients2.google.com/service/update2/crx"

;background
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsRunInBackground"=dword:00000002
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications]
"GlobalUserDisabled"=dword:00000001
[HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications]
"GlobalUserDisabled"=dword:00000000
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications]
"GlobalUserDisabled"=dword:00000001
[HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Search]
"BackgroundAppGlobalToggle"=dword:00000000
"BingSearchEnabled"=dword:00000000
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"BackgroundAppGlobalToggle"=dword:00000000

[HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"HideFileExt"=dword:00000000
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"HideFileExt"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\kernel]
;"DisableExceptionChainValidation"=dword:00000000

;SAMBA
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer]
"Start"=dword:00000004
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters]
"EnableAuthenticateUserSharing"=dword:00000000
"ServiceDllUnloadOnStop"=dword:00000001
"EnableForcedLogoff"=dword:00000001
"EnableSecuritySignature"=dword:00000001
"RequireSecuritySignature"=dword:00000001
"RestrictNullSessAccess"=dword:00000001
"SMB1"=dword:00000000
"AuditSmb1Access"=dword:00000001
"AuditClientCertificateAccess"=dword:00000001
"AuditClientDoesNotSupportEncryption"=dword:00000001
"AuditClientDoesNotSupportSigning"=dword:00000001
"AuditInsecureGuestLogon"=dword:00000001
"RejectUnencryptedAccess"=dword:00000001
"Hidden"=dword:00000001
"MinSmb2Dialect"=dword:00000311
"InvalidAuthenticationDelayTimeInMs"=dword:00000fa0
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters]
;"BlockNTLM"=dword:00000001
"EnablePlainTextPassword"=dword:00000000
"EnableSecuritySignature"=dword:00000001
"ServiceDllUnloadOnStop"=dword:00000001
"RequireSecuritySignature"=dword:00000001
"AuditServerDoesNotSupportEncryption"=dword:00000001
"AuditServerDoesNotSupportSigning"=dword:00000001
"AuditInsecureGuestLogon"=dword:00000001
"AllowInsecureGuestAuth"=dword:00000000
"RequireEncryption"=dword:00000001
"MinSmb2Dialect"=dword:00000311
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation]
"AuditServerDoesNotSupportEncryption"=dword:00000001
"AuditServerDoesNotSupportSigning"=dword:00000001
"AuditInsecureGuestLogon"=dword:00000001
"AllowInsecureGuestAuth"=dword:00000000
"RequireEncryption"=dword:00000001
"MinSmb2Dialect"=dword:00000311

[Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config]
"MinPollInterval"=dword:00000008

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions]
"CpuPriorityClass"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchProtocolHost.exe\PerfOptions]
"CpuPriorityClass"=dword:00000001

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters]
"DisableIPSourceRouting"=dword:00000002
"EnableICMPRedirect"=dword:00000000
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters]
"DisableIPSourceRouting"=dword:00000002
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging]
"EnableScriptBlockLogging"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection]
"DisallowExploitProtectionOverride"=dword:00000001
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CloudContent]
"DisableWindowsConsumerFeatures"=dword:00000001
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa]
"RestrictAnonymousSAM"=dword:00000001
"restrictanonymous"=dword:00000001
"NoLMHash"=dword:00000001
"LmCompatibilityLevel"=dword:00000005
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CredentialsDelegation]
"AllowProtectedCreds"=dword:00000001
[-HKEY_CLASSES_ROOT\search-ms]
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WinRM\Service]
"AllowBasic"=dword:00000000
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WinRM\Client]
"AllowBasic"=dword:00000000
"AllowDigest"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Installer]
"AlwaysInstallElevated"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"NoAutoplayfornonVolume"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoAutorun"=dword:00000001
"NoDriveTypeAutoRun"=dword:000000ff
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings]
"SecureProtocols"=dword:00000a00
