
@ECHO OFF
CLS
SETLOCAL ENABLEDELAYEDEXPANSION DISABLEDELAYEDEXPANSION
SET root_disk=%~d0
SET root_path=%~dp0

ECHO This script will help you with OS repairing.

ECHO Start working...
CHCP
ECHO PATH: %PATH%
CD /D "%root_path%"
ECHO ******************

ECHO ***
@REM Windows Recovery Environment (WinRE) info
reagentc.exe /info
ECHO ***
reagentc.exe /enable

@REM SFC (part 1)
SFC /?
ECHO ***
SFC.exe /VERIFYONLY /OFFLOGFILE="%root_disk%:\SFC.log"
ECHO ***
SFC.exe /SCANNOW /OFFLOGFILE="%root_disk%:\SFC.log"
ECHO ***
NOTEPAD.exe %WINDIR%\Logs\CBS\CBS.log


@REM CHKDSK
ECHO ***

ENDLOCAL && SETLOCAL ENABLEDELAYEDEXPANSION
@REM https://serverfault.com/a/268814
SET /a count=1
SET "delimiter=, "
SET "labels_free=Z Y X W V U T S R Q P O N M L K J I H G F E D C B A "
FOR /F "skip=1 tokens=1 delims= " %%a IN ('WMIC.exe LOGICALDISK GET "Caption"') DO (
    @REM Sanitizing newline and non-labels
    @REM https://newbedev.com/how-to-see-if-a-string-contains-a-substring-using-batch
    ECHO [%count%] Detected label "%%a", repairing | FIND ":"
    SET /a count=%count%+1
    SET "labels_used=!labels_used!%%a\%delimiter%"
    SET "labels_free=!labels_free:%%a =!"
    CHKDSK.exe "%SystemDrive%:\" /F /R /offlinescanandfix
    
    @REM SFC (part 1)
    SFC.exe /SCANFILE="%SystemDrive%:\windows\system32\kernel32.dll" /OFFBOOTDIR="%SystemDrive%:\" /OFFWINDIR="%SystemDrive%:\windows\" /OFFLOGFILE="%root_disk%:\SFC.log"
    SFC.exe /SCANFILE="%SystemDrive%:\windows\system32\winload.efi" /OFFBOOTDIR="%SystemDrive%:\" /OFFWINDIR="%SystemDrive%:\windows\" /OFFLOGFILE="%root_disk%:\SFC.log"
    
    @REM DISM
    ECHO ***
    @REM For PowerShell: Repair-WindowsImage -Online -RestoreHealth
    DISM.exe /?
    ECHO ***
    DISM.exe /Online /Cleanup-Image /CheckHealth /LogLevel:4 /ScratchDir:"%root_disk%:\" /Image:"%SystemDrive%:\" /LogPath:"%root_disk%:\DISM_Check.log"
    ECHO ***
    DISM.exe /Online /Cleanup-Image /ScanHealth /LogLevel:4 /ScratchDir:"%root_disk%:\" /Image:"%SystemDrive%:\" /LogPath:"%root_disk%:\DISM_Scan.log"
    ECHO ***
    DISM.exe /Online /Cleanup-Image /RestoreHealth /LogLevel:4 /ScratchDir:"%root_disk%:\" /Image:"%SystemDrive%:\" /LogPath:"%root_disk%:\DISM_Restore.log"
)
SET labels_used=%labels_used:~0,-8%
SET labels

ECHO ***
@REM BootRec (WinRE only!)
BootRec.exe /ScanOS
ECHO ***
BootRec.exe /FixMBR /FixBoot /RebuildBCD

ECHO ******************
ECHO Done working.

PAUSE
ENDLOCAL
EXIT /B %ERRORLEVEL%
