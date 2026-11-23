iwr "https://dennyhalim.github.io/cfg/windows/unattended.win10/Setup/Scripts/userupdatertask.xml"  -OutFile userupdatertask.xml
iwr "https://dennyhalim.github.io/cfg/windows/unattended.win10/Setup/Scripts/winupdatertask.xml"  -OutFile winupdatertask.xml
#schtasks /Create /TN "task1" /XML ".\task.xml" /F
Register-ScheduledTask -TaskName "updater-user" -Xml (Get-Content ".\userupdatertask.xml" -Raw) -Force
Register-ScheduledTask -TaskName "updater-system" -Xml (Get-Content ".\winupdatertask.xml" -Raw) -Force
