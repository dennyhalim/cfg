cd "%localappdata%\Mozilla\Firefox\Profiles\*.default" && rd cache2 /s /q
cd "%localappdata%\Google\Chrome\User Data\Default\" && rd cache /s /q
cd "%localappdata%\Microsoft\Windows" && rd "Temporary Internet Files" /s /q
