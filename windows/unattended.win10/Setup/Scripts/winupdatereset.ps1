Remove-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Recurse -Force
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Force -Name 'TargetReleaseVersionInfo' -PropertyType String -Value '23H2'
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Force -Name 'TargetReleaseVersion' -PropertyType DWord -Value 1
New-Item -Force  -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Force -Name 'ScheduledInstallDay ' -PropertyType DWord -Value 2"
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Force -Name 'ScheduledInstallTime ' -PropertyType DWord -Value 11
