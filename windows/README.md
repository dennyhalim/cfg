## windows registries & policies
```
curl.exe -O "https://dennyhalim.github.io/cfg/windows/unattended.win10/Setup/Scripts/setupwin11.cmd" 
.\setupwin11.cmd
```

## windows auto updater task scheduler

```
curl.exe -O  "https://dennyhalim.github.io/cfg/windows/unattended.win10/Setup/Scripts/userupdatertask.xml"
curl.exe -O  "https://dennyhalim.github.io/cfg/windows/unattended.win10/Setup/Scripts/winupdatertask.xml"
schtasks.exe /Create /TN "update-user" /XML ".\userupdatertask.xml" /F
schtasks.exe /Create /TN "update-system" /XML ".\winupdatertask.xml" /F
```

