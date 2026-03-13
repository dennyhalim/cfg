rem dont let browsers eat up all your cpu/ram
rem run from administrator's command prompt
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\opera.exe\PerfOptions" /v CpuPriorityClass /t reg_dword /d 1 /f
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\chrome.exe\PerfOptions" /v CpuPriorityClass /t reg_dword /d 1 /f
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\brave.exe\PerfOptions" /v CpuPriorityClass /t reg_dword /d 5 /f
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\firefox.exe\PerfOptions" /v CpuPriorityClass /t reg_dword /d 5 /f
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe\PerfOptions" /v CpuPriorityClass /t reg_dword /d 5 /f
Reg.exe Add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedgewebview2.exe\PerfOptions" /v CpuPriorityClass /t reg_dword /d 5 /f
