@echo off
tasklist.exe | findstr /i "%*"

rem  "$s='%SEARCH%'; Get-CimInstance Win32_Process | Where-Object { $_.Name -like \"*$s*\" -or $_.CommandLine -like \"*$s*\" } | ForEach-Object { \"PID: $($_.ProcessId)`nName: $($_.Name)`nCmd: $($_.CommandLine)`n---\" }"
rem  "$s='%~1'; $procs=Get-CimInstance Win32_Process; $procs | Where-Object { $_.Name -like \"*$s*\" -or $_.CommandLine -like \"*$s*\" } | ForEach-Object { $p=$_; $parent=$procs | Where ProcessId -eq $p.ParentProcessId; [PSCustomObject]@{ ProcessId=$p.ProcessId; Name=$p.Name; CommandLine=$p.CommandLine; ParentId=$p.ParentProcessId; ParentName=$parent.Name; ParentCmd=$parent.CommandLine } } | Format-List"
rem  "$s='%~1'; $all=Get-CimInstance Win32_Process; $all | Where { $_.Name -like \"*$s*\" -or $_.CommandLine -like \"*$s*\" } | ForEach { $p=$_; $par=$all | Where ProcessId -eq $p.ParentProcessId; try { $o=Invoke-CimMethod -InputObject $p -MethodName GetOwner; $u=\"$($o.Domain)\$($o.User)\" } catch { $u='SYSTEM' }; [PSCustomObject]@{ PID=$p.ProcessId; Name=$p.Name; User=$u; CommandLine=$p.CommandLine; ParentId=$p.ParentProcessId; ParentName=$par.Name; ParentCmd=$par.CommandLine } } | Format-List"

setlocal

if "%~1"=="" echo Usage: %~nx0 dennyhalim & exit /b 1
powershell -NoProfile -Command ^
  "$s='%~1'; $all=Get-CimInstance Win32_Process; $all | Where { $_.Name -like \"*$s*\" } | ForEach { $p=$_; $par=$all | Where ProcessId -eq $p.ParentProcessId; try { $o=Invoke-CimMethod -InputObject $p -MethodName GetOwner; $u=\"$($o.Domain)\$($o.User)\" } catch { $u='SYSTEM' }; [PSCustomObject]@{ PID=$p.ProcessId; Name=$p.Name; User=$u; CommandLine=$p.CommandLine; ParentId=$p.ParentProcessId; ParentName=$par.Name; ParentCmd=$par.CommandLine } } | Format-List"
