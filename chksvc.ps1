#dennyhalim.com


param (
[Parameter(Mandatory=$true)]
[string] $NamaService
)

Get-Service $NamaService | Where {$_.status –eq 'Stopped'} |  Start-Service
