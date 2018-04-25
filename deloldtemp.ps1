#dennyhalim.com #removing ALL files and folders with following conditions:
# inside folder named: Temp
# location: %temp% and %windir%\temp
# files/folders older than 70 days
# remove without warning
# remove the option '-WhatIf' to perform real action
# WARNING!! DANGER!!! if you remomve -WhatIf option then anything will be removed without warning. no question asked!
# if -WhatIf option remains, then nothing removed

Get-ChildItem -Path "$env:windir\Temp" -Recurse | Where-Object{$_.LastAccessTime -lt (Get-Date).AddDays(-70)} | Remove-Item -Force -Recurse -WhatIf
Get-ChildItem -Path "$env:public\..\*\AppData\Local\Temp" -Recurse | Where-Object{$_.LastAccessTime -lt (Get-Date).AddDays(-70)} | Remove-Item -Force -Recurse -WhatIf

# remove ALL browser cache
Get-ChildItem -Path "$env:public\..\*\AppData\Local\Google\Chrome\User Data\Default\Cache" -Recurse | Remove-Item -Force -Recurse -WhatIf
Get-ChildItem -Path "$env:public\..\*\AppData\Local\Microsoft\Windows\Temporary Internet Files" -Recurse | Remove-Item -Force -Recurse -WhatIf
Get-ChildItem -Path "$env:public\..\*\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2" -Recurse | Remove-Item -Force -Recurse -WhatIf

#cmd:
#forfiles.exe -p %temp% -s -m * -d -70 -c "cmd /c echo @path"
