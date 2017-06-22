#dennyhalim.com #repairing domain trust relationship problem
if(!(Test-ComputerSecureChannel)) {Test-ComputerSecureChannel -Repair}
if(!(Test-ComputerSecureChannel)) {Reset-ComputerMachinePassword}
nltest.exe /sc_reset:%USERDNSDOMAIN% ||  nltest /sc_change_pwd:%USERDNSDOMAIN%
nltest.exe /sc_verify:%USERDNSDOMAIN%
