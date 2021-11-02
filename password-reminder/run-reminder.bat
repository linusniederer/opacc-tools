@echo off
REM ***************************************************
REM ***    Run Active Directory Password Reminder   ***
REM ***************************************************

powershell -ExecutionPolicy Bypass -File "%~dp0password-reminder.ps1"
