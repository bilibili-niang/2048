@echo off
setlocal
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\build-apk.ps1"
if errorlevel 1 (
  echo Build failed.
  exit /b 1
)
echo Build completed.
