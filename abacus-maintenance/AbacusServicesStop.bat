@echo off
REM ***************************************************
REM *** 	STOP Abacus Services		 				***
REM ***************************************************

TITLE "Stop AbacusServices"
MODE con:cols=160 lines=30

REM *** Dienste stoppen
powershell -ExecutionPolicy Bypass -File "%~dp0AbacusServiceScript.ps1" STOP

pause -n