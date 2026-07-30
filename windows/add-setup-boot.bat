@echo off
rem Launcher: keeps the window open so you can read errors.
cd /d "%~dp0"
net session >nul 2>&1
if errorlevel 1 (
  echo Run this as Administrator: right-click add-setup-boot.bat -^> Run as administrator
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0add-setup-boot.ps1"
echo.
pause
