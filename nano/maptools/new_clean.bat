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
set /p prompt="Which map # would you like to clean?: " || set prompt=_None

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

if not exist "../maps/%map%.backup" (
	goto :bckup_error
)

goto :printpath

:prom_error
echo You didn't choose anything!
goto :choosemap

:bckup_error
echo ...
echo WARNING: A .backup does not exist for %map% !
echo ...
goto :choosemap


:printpath
echo ...
echo =============
echo Map filepath (This should NOT be the .backup):
echo:../maps/%map%
echo =============
goto :finalize


:finalize
echo ...
set /p finalize="Is this filepath correct?: " || set finalize=None
if "%finalize%"=="None" (goto :fin_error)
if /i "%finalize%"=="y" (goto :java)
if /i "%finalize%"=="yes" (goto :java)
if /i "%finalize%"=="n" (goto :quitmaybe)
if /i "%finalize%"=="no" (goto :quitmaybe)
goto :fin_error

:fin_error
echo ...
echo That wasn't a valid response you donk!
echo Valid responses: y, n, yes, no
goto :finalize

:java
echo Starting MapPatcher...
java -jar MapPatcher.jar -clean ../maps/%map%.backup ../maps/%map% ../maps/%map%
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