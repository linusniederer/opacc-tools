@echo off
REM ***************************************************
REM *** 	START Abacus Services		 			***
REM ***************************************************

TITLE "Start AbacusServices"
MODE con:cols=160 lines=30

REM *** Dienste starten
powershell -ExecutionPolicy Bypass -File "%~dp0AbacusServiceScript.ps1" "START"

pause -n