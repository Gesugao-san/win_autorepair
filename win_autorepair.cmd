
@ECHO OFF
:START
CLS
SETLOCAL ENABLEDELAYEDEXPANSION DISABLEDELAYEDEXPANSION
SET root_disk=%~d0
SET root_path=%~dp0

ECHO This script will help you with OS repairing.
GOTO INFO

:INFO
ECHO Start working...
CHCP
ECHO SystemDrive: "%SystemDrive%", WINDIR: "%WINDIR%", PATH: %PATH%
CD /D "%root_path%"
GOTO DiskPart

:DiskPart
GOTO WinRE

@REM Can be broken below, passing
ECHO ******************
ECHO DiskPart info > "%root_disk%:\DiskPart.log" | TYPE "%root_disk%:\reagentc.log"
DISKPART
LIST DISK
SELECT DISK 1
DETAIL DISK
LIST VOLUME
SELECT VOLUME "C:\"
DETAIL VOLUME
LIST PARTITION
SELECT PARTITION "1"
DETAIL PARTITION
EXIT
GOTO WinRE

:WinRE
ECHO ******************
ECHO Windows Recovery Environment (WinRE) info
reagentc.exe /info > "%root_disk%:\reagentc.log" | TYPE "%root_disk%:\reagentc.log"
ECHO ***
reagentc.exe /enable >> "%root_disk%:\reagentc.log" | TYPE "%root_disk%:\reagentc.log"
GOTO SFC_p1

:SFC_p1
ECHO ******************
ECHO SFC (part 1)
SFC /?
ECHO ***
SFC.exe /VERIFYONLY
ECHO ***
SFC.exe /SCANNOW
ECHO ***
NOTEPAD.exe "%WINDIR%\Logs\CBS\CBS.log"
GOTO CHKDSK

:CHKDSK
ECHO ******************
ECHO CHKDSK
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
    CHKDSK.exe "%SystemDrive%:\" /F /R /OfflineScanAndFix
    
    ECHO ***
    ECHO SFC (part 1)
    SFC.exe /SCANFILE="%SystemDrive%:\windows\system32\kernel32.dll" /OFFBOOTDIR="%SystemDrive%:\" /OFFWINDIR="%SystemDrive%:\windows\" /OFFLOGFILE="%root_disk%:\SFC.log"
    SFC.exe /SCANFILE="%SystemDrive%:\windows\system32\winload.efi" /OFFBOOTDIR="%SystemDrive%:\" /OFFWINDIR="%SystemDrive%:\windows\" /OFFLOGFILE="%root_disk%:\SFC.log"
    
    ECHO ******************
    ECHO DISM
    DISM.exe /Online /Cleanup-Image /CheckHealth /LogLevel:4 /ScratchDir:"%root_disk%:\" /Image:"%SystemDrive%:\" /LogPath:"%root_disk%:\DISM_Check.log"
    ECHO ***
    DISM.exe /Online /Cleanup-Image /ScanHealth /LogLevel:4 /ScratchDir:"%root_disk%:\" /Image:"%SystemDrive%:\" /LogPath:"%root_disk%:\DISM_Scan.log"
    ECHO ***
    DISM.exe /Online /Cleanup-Image /RestoreHealth /LogLevel:4 /ScratchDir:"%root_disk%:\" /Image:"%SystemDrive%:\" /LogPath:"%root_disk%:\DISM_Restore.log"
    
    @REM For PowerShell: Repair-WindowsImage -Online -CheckHealth
    @REM DISM.exe /?
    @REM NOTEPAD.exe "%WINDIR%\Logs\DISM\dism.log"
)
SET labels_used=%labels_used:~0,-8%
SET labels
GOTO BootRec

:BootRec
ECHO ******************
ECHO BootRec (WinRE only!)
@REM req. Diskpart Assign=Z
BootRec.exe /ScanOS > "%root_disk%:\BootRec.log" | TYPE "%root_disk%:\BootRec.log"
ECHO ***
BootRec.exe /FixMBR /FixBoot /RebuildBCD >> "%root_disk%:\BootRec.log" | TYPE "%root_disk%:\BootRec.log"

:END
ECHO ******************
ECHO Done working.

PAUSE
ENDLOCAL
EXIT /B %ERRORLEVEL%
