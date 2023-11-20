@echo off
cd "%~dp0\.."
call yarn install
call yarn prettier --write
call yarn run build
timeout /t 9
