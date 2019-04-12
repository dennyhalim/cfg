rem dennyhalim.com
rem run chrome-based browsers faster and using less process and memory
cd %appdata%\google\chrome
cd %programfiles%\google\chrome
chrome.exe --process-per-site --renderer-process-limit=1 --disk-cache-size=1
