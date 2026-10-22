# PowerShell as Admin
$regFile = ".\setup-users.reg"

# Load default hive
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"

# Fix HKCU -> DefaultUser and import
(Get-Content $regFile) -replace 'HKEY_CURRENT_USER','HKEY_USERS\DefaultUser' | Set-Content "$regFile.tmp"
reg import "$regFile.tmp"
Remove-Item "$regFile.tmp"

# Unload
reg unload "HKU\DefaultUser"

Write-Host "Imported to Default User" -ForegroundColor Green
