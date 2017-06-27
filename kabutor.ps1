$installer = "$env:windir\temp\kabutoinstaller.exe"; Invoke-WebRequest -Uri https://app.kabuto.io/dl/c/w1gowhcgaw-zmu0 -OutFile $installer; . $installer
