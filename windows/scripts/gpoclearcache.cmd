rem dennyhalim.com #fixing gpoupdate fail
cd "%ALLUSERSPROFILE%\Microsoft\Group Policy" && rd History.old /s /q
attrib -r -h -s History
move /y History History.old
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies.old" /f
REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies.old" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History.old" /f
REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History.old" /f
REG copy "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies.old" /s /f
REG copy "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies.old" /s /f
REG copy "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History" "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History.old" /s /f
REG copy "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History" "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History.old" /s /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" /f
REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History" /f
REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History" /f
DEL /F /Q C:\WINDOWS\security\Database\secedit.sdb.old
move /y %windir%\security\Database\secedit.sdb %windir%\security\Database\secedit.sdb.old
Klist purge
pause 'please restart computer'
rem gpupdate /force
