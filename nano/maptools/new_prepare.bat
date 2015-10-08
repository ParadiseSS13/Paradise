@setlocal enableextensions enabledelayedexpansion
@echo off

set /a count=0
for /f "tokens=*" %%A in ('dir /b /a-d "../maps/*.dmm"') do (
	set /a count+=1
	set num.!count!=%%A
)

for /f "tokens=2* delims=.=" %%A in ('set num.') do echo %%A = %%B

:choosemap
echo ...
set /p prompt="Which map # would you like to back up?: " || set prompt=_None

if /i "%prompt%"=="exit" (
	goto :quitmaybe
)

if "%prompt%"=="_None" (
	goto :prom_error
) else set mapnum=%prompt%

for /f "tokens=2* delims=.=" %%A in ('set num.%mapnum%') do set map=%%B

if "%map%"=="" (
	echo That's not a valid map, donklorde.
	goto :choosemap
)

goto :printpath

:prom_error
echo You didn't choose anything!
goto :choosemap

:printpath
echo ...
echo =============
echo Backing up:
echo:../maps/%map%
echo Into:
echo:../maps/%map%.backup
echo =============
goto :copymap

:copymap
echo Copying...
cd ../maps
copy %map% %map%.backup
echo Done.
goto :exit

:quitmaybe
echo ...
set /p exitmaybe="Exit the program?: " || set exitmaybe=_NothingChosen
if "%exitmaybe%"=="_NothingChosen" (goto :qm_error)
if /i "%exitmaybe%"=="y" (goto :exit)
if /i "%exitmaybe%"=="yes" (goto :exit)
if /i "%exitmaybe%"=="n" (goto :choosemap)
if /i "%exitmaybe%"=="no" (goto :choosemap)
goto :qm_error

:qm_error
echo ...
echo That wasn't a valid response, or you didn't choose anything!
echo Valid responses: y, n, yes, no
goto :quitmaybe

:exit
pause
exit

