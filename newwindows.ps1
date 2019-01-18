#dennyhalim.com

sc.exe config wuauserv start= demand
sc.exe config DiagTrack start= disabled
sc.exe config dmwappushservice start= disabled
sc.exe config RetailDemo start= disabled
sc.exe config lfsvc start= disabled
sc.exe config ssh-agent start= auto
sc.exe config sshd start= auto

Set-Service -Name wuauserv -StartupType Manual #windows auto update
Set-Service -Name winmgmt -StartupType Manual #wmi
Set-Service -Name DiagTrack -StartupType Disabled #diagnostic tracking
Set-Service -Name dmwappushservice -StartupType Disabled # tracking
Set-Service -Name WSearch -StartupType Disabled #search indexer
#Set-Service -Name SysMain -StartupType Disabled #superfetch
#Set-Service -Name Dnscache -StartupType Manual #dnsclient
#Set-Service -Name TabletInputService -StartupType Disabled
#Set-Service -Name HomeGroupProvider -StartupType Disabled
#Set-Service -Name WMPNetworkSvc -StartupType Disabled #media player network
#Set-Service -Name WPCSvc -StartupType Disabled #parental control
#Set-Service -Name WerSvc -StartupType Disabled #error reporting
#Set-Service -Name WinHttpAutoProxySvc -StartupType Disabled #wpad
#Set-Service -Name wcncsvc -StartupType Disabled #WPS
#Set-Service -Name lfsvc -StartupType Disabled #geolocation geofence
#apps services
Set-Service -Name AdobeFlashPlayerUpdateSvc -StartupType Disabled
Set-Service -Name AdobeARMservice -StartupType Disabled
Set-Service -Name MozillaMaintenance -StartupType Disabled
Set-Service -Name gupdate -StartupType Disabled
Set-Service -Name gupdatem -StartupType Disabled


#wmic.exe USERACCOUNT WHERE "Name='admin'" set PasswordExpires=FALSE
#wmic.exe USERACCOUNT WHERE "Name='user'" set PasswordExpires=FALSE

reg.exe load HKLM\DEFAULT "%Public%\..\default\ntuser.dat"
reg.exe add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People /v PeopleBand /t REG_DWORD /d 0 /f
reg.exe add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f
reg.exe add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 1 /f
reg.exe add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
reg.exe add "HKLM\DEFAULT\Software\Microsoft\Input\TIPC" /v Enabled /t REG_DWORD /d 0 /f
reg.exe add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f
reg.exe add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /v Value /d Deny /f
reg.exe delete "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /F
reg.exe unload HKLM\DEFAULT

reg.exe add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DeferUpgrade /t REG_DWORD /d 1 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v BranchReadinessLevel /t REG_DWORD /d 32 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DeferFeatureUpdates /t REG_DWORD /d 1 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DeferFeatureUpdatesPeriodinDays /t REG_DWORD /d 365 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" /v WiFiSenseCredShared /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" /v WiFiSenseOpen /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v 1 /t REG_SZ /d pool.ntp.org /f

Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowHiddenFilesFoldersDrives # -EnableShowProtectedOSFiles
#Set-ExplorerOptions -showHiddenFilesFoldersDrives -showFileExtensions #-showProtectedOSFiles #obsoletes
#Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\WDigest" -Name UseLogonCredential -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" SafeModeBlockNonAdmins -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" AllowTelemetry -Type DWORD -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" -Name 1 -Value "pool.ntp.org" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name DeferUpgrade -Type DWORD -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name IncludeRecommendedUpdates -Type DWORD -Value 0 -Force
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name IncludeRecommendedUpdates -Type DWORD -Value 0 -Force
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" EnableConnectionRateLimiting -Type DWORD -Value 1 -Force
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" NtfsDisableLastAccessUpdate -Type DWORD -Value 1 -Force


cscript.exe "%WINDIR%\System32\Printing_Admin_Scripts\en-US\prndrvr.vbs" -a -m "Canon LBP2900" -i "%WINDIR%\Setup\Drivers\CanonLBP2900\CNAB4STD.inf"
cscript.exe "%WINDIR%\System32\Printing_Admin_Scripts\en-US\prndrvr.vbs" -a -m "Canon G2000 series Printer" -i "%WINDIR%\Setup\Drivers\CanonG2000\Driver\G2000P6.inf"
rem move "%WINDIR%\Setup\Drivers\*" "%WINDIR%\INF"

schtasks.exe /change /TN "\Microsoft\Windows\Setup\SetupCleanupTask" /DISABLE
schtasks.exe /change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE
schtasks.exe /change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /DISABLE
schtasks.exe /change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE
schtasks.exe /change /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /DISABLE
schtasks.exe /change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /DISABLE

#netsh advfirewall firewall add rule dir=in action=allow profile=any protocol=TCP localport=2222 name="sshd"
# https://blogs.technet.microsoft.com/networking/2010/12/06/disabling-network-discoverynetwork-resources/
#profile=domain,private,public
netsh advfirewall firewall add rule dir=in action=block profile=any protocol=TCP localport=2869 name=disc_upnp
netsh advfirewall firewall add rule dir=in action=block profile=any protocol=TCP localport=5357 name=disc_wsdapievents
netsh advfirewall firewall add rule dir=in action=block profile=any protocol=TCP localport=5358 name=disc_wsdevents
netsh advfirewall firewall add rule dir=in action=block profile=any protocol=UDP localport=5355 name=disc_llmnr
netsh advfirewall firewall add rule dir=in action=block profile=any protocol=UDP localport=3702 name=disc_wsdpublishing
netsh advfirewall firewall add rule dir=in action=block profile=any protocol=UDP localport=1900 name=disc_ssdp



# better options: use dism for features also available on w7 and powershell for w10 only features
#Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Client -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Deprecation -NoRestart
#Disable-WindowsOptionalFeature -Online -FeatureName MediaPlayback -NoRestart
#Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart
#Disable-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-amd64 -NoRestart
#Disable-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-x86 -NoRestart

# https://aka.ms/StopUsingSMB1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 -Force
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" -Name DependOnService -Value @("bowser","mrxsmb20","nsi") -Force
#Set-Service -Name mrxsmb10 -StartupType Disabled 
#win8+
#Set-SmbServerConfiguration -EnableSMB1Protocol $false

Register-ScheduledJob -Name checkpoint -RunNow -ScriptBlock {Checkpoint-Computer -Description 'dennyhalim.com'} -Trigger @{Frequency="Weekly"; At="11:00AM"; DaysOfWeek="Monday"} -ScheduledJobOption @{RunElevated=$True}
REAGENTC.EXE /enable
rem shutdown /r /f /t 0
