@echo off
cd "%~dp0\.."
call yarn install
call yarn prettier --write
timeout /t 9
