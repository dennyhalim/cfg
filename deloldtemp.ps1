Get-ChildItem -Path "C:\Users\*\AppData\Local\Temp" -Recurse | Where-Object{$_.CreationTime -lt (Get-Date).AddDa
ys(-70)} | Remove-Item -Force
