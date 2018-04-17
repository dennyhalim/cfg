
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Client -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Deprecation -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName MediaPlayback -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-amd64 -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-x86 -NoRestart

Get-AppXProvisionedPackage -Online | Remove-AppxProvisionedPackage -Online 
Get-AppxPackage -AllUsers | Remove-AppxPackage
# Get-AppxPackage | Remove-AppxPackage

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" AllowTelemetry -Type DWORD -Value 0 -Force
Set-Service -Name wuauserv -StartupType Manual #windows auto update
Set-Service -Name DiagTrack -StartupType Disabled #diagnostic tracking
Set-Service -Name dmwappushservice -StartupType Disabled # tracking
Set-Service -Name lfsvc -StartupType Disabled #geolocation

#$d=get-item ${env:HOMEDRIVE}
#$d.Attributes='Directory,NotContentIndexed'
#$d=get-item ${env:ProgramData}
#$d.Attributes='Directory,NotContentIndexed'
$d=get-item ${env:ProgramFiles}
$d.Attributes='Directory,NotContentIndexed'
$d=get-item ${env:ProgramFiles(x86)}
$d.Attributes='Directory,NotContentIndexed'
$d=get-item ${env:windir}
$d.Attributes='Directory,NotContentIndexed'
$d=get-item d:\
$d.Attributes='Directory,NotContentIndexed'

#unpin apps
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

Enable-PSRemoting -Force -SkipNetworkProfileCheck

#Enable-ComputerRestore -drive "${env:HOMEDRIVE}"
Checkpoint-Computer -Description 'dennyhalim.com install finished'
