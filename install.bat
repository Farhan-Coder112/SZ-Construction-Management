@echo off
echo Installing SZ Construction Management System...
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges.
) else (
    echo Please run this installer as administrator.
    echo Right-click the file and select "Run as administrator".
    pause
    exit /b 1
)

REM Set installation directory
set "INSTALL_DIR=C:\Program Files\SZ Construction Management"
set "APP_NAME=SZ Construction Management"

echo Creating installation directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo Copying application files...
xcopy "build\windows\x64\runner\Release" "%INSTALL_DIR%\" /E /I /Y

echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\%APP_NAME%.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\sz_construction_management.exe'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = '%APP_NAME%'; $Shortcut.Save()"

echo Creating Start Menu shortcut...
if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\SZ Construction Management" mkdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\SZ Construction Management"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\SZ Construction Management\%APP_NAME%.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\sz_construction_management.exe'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = '%APP_NAME%'; $Shortcut.Save()"

echo.
echo Installation completed successfully!
echo.
echo You can now run the application from:
echo - Desktop shortcut
echo - Start Menu
echo - Or directly from: %INSTALL_DIR%\sz_construction_management.exe
echo.
pause
