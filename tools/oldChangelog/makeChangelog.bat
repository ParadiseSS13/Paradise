@echo off
rem Cheridan asked for this. - N3X
rem This has been updated to use the old changelog directories as of PR #13051 -AA
call python ss13_genchangelog.py ../../html/archived_changelog/changelog.html ../../html/archived_changelog/changelogs
pause
