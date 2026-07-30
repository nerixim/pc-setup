@echo off
setlocal EnableExtensions

rem Drive letter of the NTFS volume that holds the copied Windows ISO files (no colon).
set "LETTER=S"

if not exist "%LETTER%:\sources\boot.wim" (
  echo Missing %LETTER%:\sources\boot.wim — copy the ISO contents to %LETTER%: first.
  exit /b 1
)
if not exist "%LETTER%:\sources\boot.sdi" (
  echo Missing %LETTER%:\sources\boot.sdi
  exit /b 1
)

bcdedit /create {ramdiskoptions} /d "Ramdisk options" >nul 2>&1
bcdedit /set {ramdiskoptions} ramdisksdidevice partition=%LETTER%:
bcdedit /set {ramdiskoptions} ramdisksdipath \sources\boot.sdi
if errorlevel 1 (
  echo Failed to configure {ramdiskoptions}. Run this script from Admin Command Prompt.
  exit /b 1
)

set "ID="
for /f "tokens=2 delims={}" %%A in ('bcdedit /create /d "Windows 11 Setup" /application osloader') do set "ID={%%A}"
if not defined ID (
  echo Failed to create boot entry.
  exit /b 1
)

echo Using boot entry %ID%

bcdedit /set %ID% device ramdisk=[%LETTER%:]\sources\boot.wim,{ramdiskoptions}
bcdedit /set %ID% osdevice ramdisk=[%LETTER%:]\sources\boot.wim,{ramdiskoptions}
bcdedit /set %ID% path \windows\system32\boot\winload.efi
bcdedit /set %ID% systemroot \windows
bcdedit /set %ID% detecthal yes
bcdedit /set %ID% winpe yes
bcdedit /displayorder %ID% /addlast
bcdedit /timeout 10

echo.
echo Done. Reboot and choose "Windows 11 Setup".
endlocal
