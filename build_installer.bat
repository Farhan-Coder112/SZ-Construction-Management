@echo off
echo Building SZ Construction Management Installer...
echo.

REM Check if Inno Setup is installed
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set ISCC="C:\Program Files\Inno Setup 6\ISCC.exe"
) else (
    echo ERROR: Inno Setup not found!
    echo Please download and install Inno Setup from https://jrsoftware.org/isdl.php
    pause
    exit /b 1
)

REM Compile the installer
%ISCC% installer_script.iss

echo.
if %ERRORLEVEL% EQU 0 (
    echo SUCCESS! Installer created successfully!
    echo Check the Output folder for the .exe file.
) else (
    echo FAILED to build installer!
)
pause
