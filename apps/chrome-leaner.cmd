rem dennyhalim.com
rem run chrome-based browsers faster and using less process and memory
rem might also works on chrome-based browsers and apps like edge, opera, brave, iridium, epicbrowser, rambox, etc
cd "%appdata%\google\chrome\application"
cd "%programfiles%\google\chrome\application"
cd "%programfiles(x86)%\google\chrome\application"
chrome.exe --process-per-site --renderer-process-limit=1 --TotalMemoryLimitMb=1024 --disk-cache-size=123456789 

rem #enable dns-over-https
rem #enable this in chrome/opera/edge browser: chrome://flags/#dns-over-https
