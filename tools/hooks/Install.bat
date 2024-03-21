@call "%~dp0\..\bootstrap\python" -m hooks.install %*
@echo off
set /p choice=Do you want to install TGUI hooks (requires Node.js)? (Y/N):

if /i "%choice%"=="Y" (
    @echo off
	rem Copyright (c) 2020 Aleksej Komarov
	rem SPDX-License-Identifier: MIT
	call powershell.exe -NoLogo -ExecutionPolicy Bypass -File "%~dp0\..\..\tgui\bin\tgui_.ps1" --install-git-hooks %*
	rem Pause if launched in a separate shell unless initiated from powershell
	echo %PSModulePath% | findstr %USERPROFILE% >NUL
	if %errorlevel% equ 0 (
		pause
		exit 0
		)
	echo %cmdcmdline% | find /i "/c"
)
pause
