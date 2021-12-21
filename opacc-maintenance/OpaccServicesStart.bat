@echo off
REM ***************************************************
REM *** 	START Opacc Services		 			***
REM ***************************************************

TITLE "Start OpaccServices"
MODE con:cols=160 lines=30

REM *** Dienste starten
powershell -ExecutionPolicy Bypass -File "%~dp0OpaccServiceScript.ps1" "START"

pause -n