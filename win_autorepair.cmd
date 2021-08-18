
@ECHO OFF
CLS
SETLOCAL ENABLEDELAYEDEXPANSION DISABLEDELAYEDEXPANSION
SET root_path=%~dp0

ECHO This script will help you with OS repairing.

ECHO Start working...
CHCP
CD /D "%root_path%"
ECHO ******************

SFC /SCANNOW
DISM /Online /Cleanup-image /ScanHealth
DISM /Online /Cleanup-image /RestoreHealth
CHKDSK "%SystemDrive%\" /F /R /scan /offlinescanandfix

ECHO ******************
ECHO Done working.

PAUSE
ENDLOCAL
EXIT /B %ERRORLEVEL%
