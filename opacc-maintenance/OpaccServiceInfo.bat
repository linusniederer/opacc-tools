@echo off
REM ***************************************************
REM *** 	INFO Opacc Services		 				***
REM ***************************************************

TITLE "OpaccServices Information"
MODE con:cols=160 lines=40

REM *** Dienste auf allen ServiceBusNodes anzeigen
powershell -ExecutionPolicy Bypass -File "%~dp0OpaccServiceScript.ps1"

pause -n