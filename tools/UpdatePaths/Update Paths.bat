@echo off
call "%~dp0\..\bootstrap\python" -m UpdatePaths %* -d "%~dp0/../../_maps/map_files220"
pause
