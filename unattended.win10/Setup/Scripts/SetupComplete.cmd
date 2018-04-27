@echo off
rem dennyhalim.com
rem this will be copied after first reboot and then run after next reboot

#replace defaultlayouts before it gets created
move "%Public%\..\Default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml" "%Public%\..\Default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.dennyhalim" 
copy /y "%WINDIR%\Setup\Files\DefaultLayouts.xml" "%Public%\..\Default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml"
move "%SystemRoot%\SysWOW64\OneDriveSetup.exe" "%SystemRoot%\SysWOW64\OneDriveSetup.dennyhalim"
move "%SystemRoot%\System32\OneDriveSetup.exe" "%SystemRoot%\System32\OneDriveSetup.dennyhalim"
rem move "%windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy" "%windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy.dennyhalim"
rem startmenu disabled if shellex disabled
rem move "%windir%\SystemApps\ShellExperienceHost_cw5n1h2txyewy" "%windir%\SystemApps\ShellExperienceHost_cw5n1h2txyewy.dennyhalim"

reg load HKLM\DEFAULT "%Public%\..\default\ntuser.dat"
reg add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 1 /f
reg add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\DEFAULT\Software\MicrosoftMicrosoft\Input\TIPC" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f
reg add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People /v PeopleBand /t REG_DWORD /d 0 /f
reg delete "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /F
reg unload HKLM\DEFAULT

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DeferUpgrade /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v BranchReadinessLevel /t REG_DWORD /d 32 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DeferFeatureUpdates /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DeferFeatureUpdatesPeriodinDays /t REG_DWORD /d 365 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" /v WiFiSenseCredShared /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" /v WiFiSenseOpen /t REG_DWORD /d 0 /f

rem cscript "%WINDIR%\System32\Printing_Admin_Scripts\en-US\prndrvr.vbs" a -m "Canon LBP2900" -i "%WINDIR%\Setup\Files\CanonLBP2900\CNAB4STD.inf"
rem cscript "%WINDIR%\System32\Printing_Admin_Scripts\en-US\prndrvr.vbs" a -m "Canon G2000 series Printer" -i "%WINDIR%\Setup\Files\CanonG2000\Driver\G2000P6.inf"
move "%WINDIR%\Setup\Drivers\*" "%WINDIR%\INF"

"%WINDIR%\Setup\Files\chocolatey.exe" /S
"%WINDIR%\Setup\Files\Firefox Setup 52.6.0esr.exe" -ms
"%WINDIR%\Setup\Files\vlc-3.0.1-win64.exe" /L=1033 /S
"%WINDIR%\Setup\Files\SumatraPDF-3.1.2-64-install.exe" /S
Msiexec /q /I "%WINDIR%\Setup\Files\7z1801-x64.msi"
Msiexec /q /I "%WINDIR%\Setup\Files\GoogleChromeStandaloneEnterprise64.msi"
Msiexec /q /I "%WINDIR%\Setup\Files\LibreOffice_5.4.6_Win_x64.msi"
rem "%WINDIR%\Setup\Files\avira_pc_cleaner_en.exe" /s
"%WINDIR%\Setup\Files\mb3-setup-consumer-3.4.5.2467-1.0.342-1.0.4664.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
"%WINDIR%\Setup\Files\avast_business_antivirus_managed_setup_offline_silent.exe"

mkdir "%Public%\Desktop.dennyhalim"
move "%Public%\Desktop\*.*" "%Public%\Desktop.dennyhalim"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%WINDIR%\Setup\Files\setup.ps1'"

rem "%WINDIR%\Setup-githubbox.exe"
rem rd /q /s "%WINDIR%\Setup\Files"
rem del /q /f "%0"
