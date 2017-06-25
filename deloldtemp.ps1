#dennyhalim.com #removing ALL files in each and every users' AND windows' %temp% folder older than 70 days
#WARNING!! DANGER!!! anything will be removed without warning. no question asked!

Get-ChildItem -Path "C:\Users\*\AppData\Local\Temp" -Recurse | Where-Object{$_.LastAccessTime -lt (Get-Date).AddDays(-70)} | Remove-Item -Force -Recurse
Get-ChildItem -Path "$env:windir\Temp" -Recurse | Where-Object{$_.LastAccessTime -lt (Get-Date).AddDays(-70)} | Remove-Item -Force -Recurse

#cmd:
#forfiles.exe -p %temp% -s -m *.* -d -70 -c "cmd /c echo @path"
