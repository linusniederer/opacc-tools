@echo off
REM ***************************************************
REM *** 	INFO Abacus Services		 				***
REM ***************************************************

TITLE "AbacusServices Information"
MODE con:cols=160 lines=40

REM *** Dienste auf allen ServiceBusNodes anzeigen
powershell -ExecutionPolicy Bypass -File "%~dp0AbacusServiceScript.ps1"

pause -n