@echo off
REM ***************************************************
REM *** 	RESTART Abacus Services		 			***
REM ***************************************************

TITLE "Restart AbacusServices"
MODE con:cols=160 lines=30

REM *** Dienste restart
powershell -ExecutionPolicy Bypass -File "%~dp0AbacusServiceScript.ps1" "RESTART"
