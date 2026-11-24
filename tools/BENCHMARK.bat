@echo off
cd /d "%~dp0"
start "" /wait "%~dp0GENESIS47.exe" -- --benchmark
if errorlevel 1 pause
