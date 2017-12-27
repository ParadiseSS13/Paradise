@echo off
SET RELATIVEROOT="../../"
python map_conflict_fixer.py %1 %RELATIVEROOT% 0
pause
