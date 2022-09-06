rem matikan servis
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer" /f /v Start /t REG_DWORD /d 4

rem http://aka.ms/StopUsingSMB1
rem matikan samba1
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /f /v SMB1 /t REG_DWORD /d 0 

rem audit samba1
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /f /v AuditSmb1Access /t REG_DWORD /d 1

rem firewall block
netsh advfirewall firewall add rule name="block-netbios-udp" protocol=udp dir=in action=block localport=135-139
netsh advfirewall firewall add rule name="block-netbios-tcp" protocol=tcp dir=in action=block localport=135-139
netsh advfirewall firewall add rule name="block-samba" protocol=tcp dir=in action=block localport=445
