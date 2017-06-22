#dennyhalim.com #backup group policy
Import-Module grouppolicy 
$date = get-date -format M.d.yyyy 
New-Item -Path \\backupserver\gpo\$date -ItemType directory 
date >>  \\backupserver\gpo\$date.log
Backup-Gpo -All -Path \\backupserver\gpo\$date >> \\backupserver\gpo\$date.log
