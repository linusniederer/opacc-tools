@echo off
REM ***************************************************
REM *** 	RESTART Opacc Services		 			***
REM ***************************************************

TITLE "Restart OpaccServices"
MODE con:cols=160 lines=30

REM *** Dienste restart
powershell -ExecutionPolicy Bypass -File "%~dp0OpaccServiceScript.ps1" "RESTART"
