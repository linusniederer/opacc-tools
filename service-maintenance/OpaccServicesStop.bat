@echo off
REM ***************************************************
REM *** 	STOP Opacc Services		 				***
REM ***************************************************

TITLE "Stop OpaccServices"
MODE con:cols=160 lines=30

REM *** Dienste stoppen
powershell -ExecutionPolicy Bypass -File "%~dp0OpaccServiceScript.ps1" STOP

pause -n