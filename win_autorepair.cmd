
@ECHO OFF
CLS
SETLOCAL ENABLEDELAYEDEXPANSION DISABLEDELAYEDEXPANSION
SET root_path=%~dp0

ECHO This script will help you with OS repairing.

ECHO Start working...
CHCP
CD /D "%root_path%"
ECHO ******************

@REM SFC
SFC /?
ECHO ***
SFC /SCANNOW

@REM DISM
ECHO ***
@REM For PowerShell: Repair-WindowsImage -Online -RestoreHealth
DISM /?
ECHO ***
DISM /Online /Cleanup-image /CheckHealth
ECHO ***
DISM /Online /Cleanup-image /ScanHealth
ECHO ***
DISM /Online /Cleanup-image /RestoreHealth

@REM CHKDSK
ECHO ***
CHKDSK "%SystemDrive%" /F /R /offlinescanandfix

ECHO ******************
ECHO Done working.

PAUSE
ENDLOCAL
EXIT /B %ERRORLEVEL%
