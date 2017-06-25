#dennyhalim.com #removing ALL files in each and every users' %temp% folder older than 70 days
#DANGER!!! anything will be removed without warning. no question asked!

Get-ChildItem -Path "C:\Users\*\AppData\Local\Temp" -Recurse | Where-Object{$_.LastAccessTime -lt (Get-Date).Add
Days(-70)} | Remove-Item -Force -Recurse
