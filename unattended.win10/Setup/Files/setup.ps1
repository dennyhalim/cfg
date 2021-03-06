#dennyhalim.com

# Get-AppxPackage | Remove-AppxPackage
#Get-AppXProvisionedPackage -Online | where-object {$_.packagename -like "*Xbox*" -or $_.packagename -like "*zune*"} | Remove-AppxProvisionedPackage -Online 
#Get-AppxPackage -AllUsers | where-object {$_.name -like "*Xbox*" -or $_.packagename -like "*zune*"} | Remove-AppxPackage
Get-AppXProvisionedPackage -Online | where-object {$_.packagename -notlike "*Microsoft*" -and $_.packagename -notlike "*acer*"} | Remove-AppxProvisionedPackage -Online 
Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*Microsoft*" -and $_.name -notlike "*acer*"} | Remove-AppxPackage

#$d=get-item ${env:HOMEDRIVE}
#$d.Attributes='Directory,NotContentIndexed'
#$d=get-item ${env:ProgramData}
#$d.Attributes='Directory,NotContentIndexed'
$d=get-item ${env:ProgramFiles}
$d.Attributes='Directory,NotContentIndexed'
$d=get-item ${env:ProgramFiles(x86)}
$d.Attributes='Directory,NotContentIndexed'
$d=get-item ${env:SystemRoot}
$d.Attributes='Directory,NotContentIndexed'
$d=get-item d:\
$d.Attributes='Directory,NotContentIndexed'


#unpin apps (must be run per user)
(New-Object -Com Shell.Application).
    NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
    Items() |
  %{ $_.Verbs() } |
  ?{$_.Name -match 'Un.*pin from Start'} |
  %{$_.DoIt()}



#task
	$actions = (New-ScheduledTaskAction –Execute '%ProgramData%\chocolatey\choco.exe upgrade chocolatey -y'),(New-ScheduledTaskAction –Execute '%ProgramData%\chocolatey\choco.exe upgrade all -y')
	$trigger = New-ScheduledTaskTrigger -Daily -At '11:44 AM'
	$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest
	$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable
	$task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask chocoupgrade -InputObject $task

Set-MpPreference -Force -SevereThreatDefaultAction Remove -HighThreatDefaultAction Quarantine -ModerateThreatDefaultAction Quarantine -LowThreatDefaultAction Clean -RemediationScheduleDay 6 -RemediationScheduleTime 11:00 -ScanScheduleDay 0 -ScanScheduleTime 09:00 -SignatureUpdateInterval 3 -SubmitSamplesConsent Never
Enable-PSRemoting -Force -SkipNetworkProfileCheck

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

#Enable-ComputerRestore -drive "${env:HOMEDRIVE}"
Register-ScheduledJob -Name checkpoint -RunNow -ScriptBlock {Checkpoint-Computer -Description 'dennyhalim.com'} -Trigger @{Frequency="Weekly"; At="11:00AM"; DaysOfWeek="Monday"} -ScheduledJobOption @{RunElevated=$True}
