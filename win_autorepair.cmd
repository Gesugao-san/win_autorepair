
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

@REM CHKDSK "%SystemDrive%" /F /R /offlinescanandfix


ENDLOCAL && SETLOCAL ENABLEDELAYEDEXPANSION
@REM https://serverfault.com/a/268814
SET /a count=1
SET "delimiter=, "
SET "labels_free=Z:\ Y:\ X:\ W:\ V:\ U:\ T:\ S:\ R:\ Q:\ P:\ O:\ N:\ M:\ L:\ K:\ J:\ I:\ H:\ G:\ F:\ E:\ D:\ C:\ B:\ A:\ "
FOR /F "skip=1 tokens=1 delims= " %%a IN ('wmic logicaldisk get caption') DO (
    @REM Sanitizing newline and non-labels
    @REM https://newbedev.com/how-to-see-if-a-string-contains-a-substring-using-batch
    ECHO [%count%] Detected label "%%a", repairing | FIND ":"
    SET /a count=%count%+1
    SET "labels_used=!labels_used!%%a\%delimiter%"
    SET "labels_free=!labels_free:%%a =!"
    CHKDSK "%SystemDrive%" /F /R /offlinescanandfix
)
SET labels_used=%labels_used:~0,-8%
SET labels

ECHO ******************
ECHO Done working.

PAUSE
ENDLOCAL
EXIT /B %ERRORLEVEL%
