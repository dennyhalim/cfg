@rem https://fix10.isleaked.com/
sc delete DiagTrack
sc delete dmwappushservice
echo "" > C:\ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

@rem https://fix10.isleaked.com/oldwindows.html
@rem Delete KB2976978 (telemetry for Win8/8.1)
start /w wusa.exe /uninstall /kb:2976978 /quiet /norestart
@rem Delete KB3075249 (telemetry for Win7/8.1)
start /w wusa.exe /uninstall /kb:3075249 /quiet /norestart
@rem Delete KB3080149 (telemetry for Win7/8.1)
start /w wusa.exe /uninstall /kb:3080149 /quiet /norestart
@rem Delete KB3021917 (telemetry for Win7)
start /w wusa.exe /uninstall /kb:3021917 /quiet /norestart
@rem Delete KB3022345 (telemetry)
start /w wusa.exe /uninstall /kb:3022345 /quiet /norestart
@rem Delete KB3068708 (telemetry)
start /w wusa.exe /uninstall /kb:3068708 /quiet /norestart
@rem Delete KB3044374 (Get Windows 10 for Win8.1)
start /w wusa.exe /uninstall /kb:3044374 /quiet /norestart
@rem Delete KB3035583 (Get Windows 10 for Win7sp1/8.1)
start /w wusa.exe /uninstall /kb:3035583 /quiet /norestart
@rem Delete KB2990214 (Get Windows 10 for Win7 without sp1)
start /w wusa.exe /uninstall /kb:2990214 /quiet /norestart
@rem Delete KB2990214 (Get Windows 10 for Win7)
start /w wusa.exe /uninstall /kb:2990214 /quiet /norestart
@rem Delete KB2952664 (Get Windows 10 assistant)
start /w wusa.exe /uninstall /kb:2952664 /quiet /norestart
@rem Delete KB3075853 (update for "Windows Update" on Win8.1/Server 2012R2)
start /w wusa.exe /uninstall /kb:3075853 /quiet /norestart
@rem Delete KB3065987 (update for "Windows Update" on Win7/Server 2008R2)
start /w wusa.exe /uninstall /kb:3065987 /quiet /norestart
@rem Delete KB3050265 (update for "Windows Update" on Win7)
start /w wusa.exe /uninstall /kb:3050265 /quiet /norestart
@rem Delete KB3075851 (update for "Windows Update" on Win7)
start /w wusa.exe /uninstall /kb:971033 /quiet /norestart
@rem Delete KB2902907 (description is not available)
start /w wusa.exe /uninstall /kb:2902907 /quiet /norestart
