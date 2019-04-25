rem dennyhalim.com
rem run chrome-based browsers faster and using less process and memory
rem might also works on chrome-based browsers and apps like opera, brave, iridium, epicbrowser, rambox, etc
cd "%appdata%\google\chrome\application"
cd "%programfiles%\google\chrome\application"
cd "%programfiles(x86)%\google\chrome\application"
chrome.exe --process-per-site --renderer-process-limit=1 --disk-cache-size=1
