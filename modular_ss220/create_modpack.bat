@echo off
set /p modpackName=Enter modpack name :

xcopy "example" "%modpackName%" /s /i

ren "%modpackName%\_example.dm" "_%modpackName%.dm"
ren "%modpackName%\_example.dme" "_%modpackName%.dme"
ren "%modpackName%\code\example.dm" "%modpackName%.dm"

Powershell -Command "(Get-Content '%modpackName%\_%modpackName%.dm') -replace 'Example modpack', '%modpackName%' | Set-Content '%modpackName%\_%modpackName%.dm'"
Powershell -Command "(Get-Content '%modpackName%\_%modpackName%.dme') -replace 'Example modpack', '%modpackName%' | Set-Content '%modpackName%\_%modpackName%.dme'"
Powershell -Command "(Get-Content '%modpackName%\_%modpackName%.dm') -replace 'example', '%modpackName%' | Set-Content '%modpackName%\_%modpackName%.dm'"
Powershell -Command "(Get-Content '%modpackName%\_%modpackName%.dme') -replace 'example', '%modpackName%' | Set-Content '%modpackName%\_%modpackName%.dme'"
