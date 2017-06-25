Get-ChildItem -Path "C:\Users\*\AppData\Local\Temp" -Recurse | Where-Object{$_.LastAccessTime -lt (Get-Date).Add
Days(-70)} | Remove-Item -Force
