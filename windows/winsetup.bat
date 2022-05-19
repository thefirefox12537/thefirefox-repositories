@echo off

REM  Windows Setup
REM  Copyright (C) Microsoft Corporation. All rights reserved.
REM
REM  Date created:    04/03/2022  4:48pm
REM  System created:  Windows 11 Pro
REM
REM  This script created by:
REM    Faizal Hamzah
REM    The Firefox Flasher
REM
REM  Program requirement:   DISM.EXE IMAGEX.EXE NET.EXE

REM  VersionInfo:
REM
REM    File version:      6,0,6000,0
REM    Product Version:   6,0,6000,0
REM
REM    CompanyName:       Microsoft Corporation
REM    FileDescription:   Windows Setup
REM    FileVersion:       6.0.6000.0
REM    InternalName:      winsetup
REM    LegalCopyright:    © Microsoft Corporation. All rights reserved.
REM    OriginalFileName:  WINSETUP.BAT
REM    ProductName:       Microsoft® Windows® Operating System
REM    ProductVersion:    6.0.6000.0


:start
if %OS%!==Windows_NT! goto runwinnt

:runos_2
ver|find "Operating System/2" > nul
if not errorlevel 1 goto windos_2

:runwindos
if exist %windir%\..\msdos.sys find "WinDir" %windir%\..\msdos.sys > nul
if not errorlevel 1 goto windos_2
goto msdos

:runwinnt
@setlocal
@break on
for %%v in (Daytona Cairo Hydra Neptune NT) do ^
ver|find "%%v" > nul & ^
if not errorlevel 1 (set OLD_WINNT=1)

if %OLD_WINNT%!==1! (goto ntold) ^
else (setlocal enableextensions enabledelayedexpansion)

for /f "tokens=4-6 delims=[.NT] " %%v in ('ver') do (
for %%a in (5.00 5.10 5.1 5.2 5.3 5.4) do ^
if "%%w.%%x"=="%%a" (goto ntold) else ^
if "%%v.%%w"=="%%b" (goto ntold)
)

set _UPPER=ABCDEFGHIJKLMNOPQRSTUVWXYZ
set _LOWER=abcdefghijklmnopqrstuvwxyz

set _CONVERT_STRING= ^
for /l %%a in (0,1,25) do ^
call set "_1=%%_UPPER:~%%~a,1%%" ^& ^
call set "_2=%%_LOWER:~%%~a,1%%" ^& ^
call set

set _ARGS=%*
set _FILE=%~n0
set _PARAM=%~1
set _DRV1=%~2
set _DRV2=%~3
set _TYPE=%~4

if defined _ARGS (
set _ARGS=%_ARGS:"=%
for %%s in (ARGS PARAM) do %_CONVERT_STRING% "_%%~s=%%_%%~s:!_1!=!_2!%%"
for %%s in (FILE DRV1 DRV2 TYPE) do %_CONVERT_STRING% "_%%~s=%%_%%~s:!_2!=!_1!%%"
)

for %%a in (%_ARGS%) do (
for %%b in (
fdisk install
adduser addadmin
bypassnro skipoobe
skipoobenew rollinsider
) do ^
if "%%a"=="/%%~b" (set "stepgoto=%%~b")
if "%%a"=="/?" (goto :help)
if "%%a"=="" (goto :help)
)
if not defined stepgoto (goto :help)

for %%d in ("%SystemRoot%\system32\config\default") do ^
if not "%SystemRoot:~0,2%"=="X:" (icacls.exe %%~dpd\system > nul 2>&1) ^
else (bcdedit.exe /store %%~dpd\bcd-template > nul 2>&1)
if %ERRORLEVEL% NEQ 0 (goto :require_admin)

set drive=CDEFGHIJKLMNOPQRSTUVWXYZ
set alpha=abcdefghijklmnopqrstuvwyz0

if defined stepgoto (goto :%stepgoto%)
goto :help

:fdisk
for %%a in (%PATHEXT:.=%) do ^
for %%f in (fdisk.%%a) do ^
if exist %%~$PATH:f (set diskmgmt=%%f) else ^
if exist %%~dpff (set diskmgmt=%%f)

if not defined diskmgmt ^
for %%f in (diskpart.exe) do ^
if exist %%~$PATH:f (set diskmgmt=%%f)

@call %diskmgmt% & echo off
@goto end_of_exit

:install
if not "%SystemRoot:~0,2%"=="X:" (goto :require_winpe)
for %%a in ("Setup" "Setup\MoSetup") do ^
reg.exe add HKLM\SYSTEM\%%~a /f /t REG_DWORD /v AllowUpgradesWithUnsupportedTPMOrCPU /d 1 > nul 2>&1
for %%a in (BypassTPMCheck BypassStorageCheck BypassSecureBootCheck BypassRAMCheck BypassCPUCheck) do (
reg.exe add HKLM\SYSTEM\Setup\LabConfig /f /t REG_DWORD /v %%a /d 1 > nul 2>&1
reg.exe add HKLM\Setup\LabConfig /f /t REG_DWORD /v %%a /d 1 > nul 2>&1
)
::IMAGEX
for %%i in ("imagex.exe") do ^
for /l %%d in (0,1,23) do ^
if exist "!drive:~%%~d,1!:\sources\%%~i" (set "imagexcd=!drive:~%%~d,1!:\sources\%%~i")
for %%f in ("%~dp0\%%~i" %imagexcd% %%~$PATH:i) do ^
if exist "%%~f" (set "imagex=%%~f")
if defined imagex (set "imaging=imagex" & goto :next1)
::DISM
for %%d in ("dism.exe") do ^
if exist %%~$PATH:d ^
for /f "usebackq tokens=2-3 delims=:. " %%v in (`call %%~$PATH:d^|find /i "Version:"`) do ^
if %%v EQU 6 (if %%w LSS 2 (goto :ntold)) else ^
if %%v LSS 6 (goto :ntold) ^
else (set "dism=%%~$PATH:d")
if defined dism (set "imaging=dism" & goto :next1)

:next1
if %2!==! (goto :no_targetpath) else ^
if "%_DRV1:~0,1%"=="A" (goto :no_allowfloppy) else ^
if "%_DRV1:~0,1%"=="B" (goto :no_allowfloppy) else ^
if not exist %_DRV1% (goto :no_targetexist)
if %3!==! (goto :no_args)

for %%a in ("sources\install") do ^
for /l %%d in (0,1,23) do ^
if exist "!drive:~%%~d,1!:\%%~a.wim" (
set "opt=imagefile"
set "installsrc=!drive:~%%~d,1!:\sources\install.wim"
) else ^
if exist "!drive:~%%~d,1!:\%%~a.swm" (
set "opt=imagefile"
set "installsrc=!drive:~%%~d,1!:\sources\install.swm"
set "imagexswm=/ref ^"!drive:~%%~d,1!:\sources\install*.swm^""
set "dismswm=/swmfile:^"!drive:~%%~d,1!:\sources\install*.swm^""
) else ^
if exist "!drive:~%%~d,1!:\%%~a.esd" (
set "opt=imagefile"
set "installsrc=!drive:~%%~d,1!:\sources\install.esd"
)

if not defined opt (goto :require_wim)
if defined imaging (goto :next2)
goto :require_imaging

:next2
set "SPACE= "
echo Type the available index number to install Windows.
:loopinstall
echo.
echo Install source: %installsrc%
echo Available edition:
if "%imaging%"=="dism" ^
for /f "tokens=2* delims=:" %%a in ('call %dism% /get-imageinfo /%opt%:"%installsrc%"^|find /i "Name"') do ^
if "%%~a"=="%SPACE%" (echo.  NOT IDENTIFIED EDITION >> "%tmp%\%~n0.txt") ^
else (echo  %%~a >> "%tmp%\%~n0.txt")
if "%imaging%"=="imagex" ^
for /f "tokens=3* delims=><" %%a in ('call %imagex% /info "%installsrc%"^|find /i "<NAME>"') do ^
if "%%~a"=="%SPACE%" (echo.  NOT IDENTIFIED EDITION >> "%tmp%\%~n0.txt") ^
else (echo  %%~a >> "%tmp%\%~n0.txt")
type "%tmp%\%~n0.txt"|find /n "%SPACE%" && del /f /q "%tmp%\%~n0.txt" > nul 2>&1
echo.
set /p "INDEX=INDEX> "
if defined INDEX (%_CONVERT_STRING% "INDEX=%%INDEX:!_2!=!_1!%%") ^
else (goto :invalid_edition)
for /l %%s in (0,1,25) do ^
if %INDEX%?==!alpha:~%%~s,1!? (goto :invalid_edition)
if %INDEX%?==X? (echo Exitting...& goto :end_of_exit)

echo Expanding Windows...
if "%imaging%"=="dism" (call %dism% /apply-image /%opt%:"%installsrc%" %dismswm% /index:%INDEX% /applydir:%_DRV1%\)
if "%imaging%"=="imagex" (call %imagex% /apply "%installsrc%" %imagexswm% %INDEX% %_DRV1%\)
if %ERRORLEVEL% NEQ 0 (goto :installerror)
if not exist %_DRV1%\Windows (goto :installerror)

:buildbcd
echo Cleaning old Boot Configuration Data store and information log...
for %%i in (
autoexec.* command.* config.* ibmbio.* ibmdos.* io.* msdos.*
bootsect.* bootmgr.* BOOTNXT BOOTTGT boot.ini NTDETECT.COM NTLDR
*.ini *.txt *.log *.sys
) do (
del /f /ashr /q %_DRV1%\%%~i > nul 2>&1
del /f /ashr /q %_DRV2%\%%~i > nul 2>&1
attrib.exe -s -h -r %_DRV1%\%%~i > nul 2>&1
attrib.exe -s -h -r %_DRV2%\%%~i > nul 2>&1
del /f /q %_DRV1%\%%~i > nul 2>&1
del /f /q %_DRV2%\%%~i > nul 2>&1
)
for %%d in (boot efi recovery) do (
rmdir /s /q %_DRV1%\%%~d > nul 2>&1
rmdir /s /q %_DRV2%\%%~d > nul 2>&1
)

echo Rebuilding Boot Configuration Data store...
for %%a in (%_ARGS%) do (
if "%%a"=="/all" (
call %SystemRoot%\system32\bcdboot.exe %_DRV1%\Windows /s %_DRV2% /f BIOS > nul 2>&1
call %SystemRoot%\system32\bootsect.exe /nt60 %_DRV2% /mbr > nul 2>&1
)
if "%%a"=="/efi" (
call %SystemRoot%\system32\bcdboot.exe %_DRV1%\Windows /s %_DRV2% /f UEFI > nul 2>&1
)
if "%%a"=="/mbr" (
for %%w in (2K3 XP 2K) do if "%%w"=="%_TYPE%" set "nt5=%%w"
if not defined nt5 (
if not defined _TYPE (
call %SystemRoot%\system32\bcdboot.exe %_DRV1%\Windows /s %_DRV2% /f all > nul 2>&1
call %SystemRoot%\system32\bootsect.exe /nt60 %_DRV2% /mbr /force > nul 2>&1
) else (
call %SystemRoot%\system32\bcdboot.exe %_DRV1%\Windows /f BIOS > nul 2>&1
call %SystemRoot%\system32\bootsect.exe /nt60 %_DRV1% /mbr > nul 2>&1
))
))

if "%nt5%"=="2K3" (call :make_bootnt5 2K3 WINDOWS "Microsoft Windows Server 2003")
if "%nt5%"=="XP" (call :make_bootnt5 XP WINDOWS "Microsoft Windows XP")
if "%nt5%"=="2K" (call :make_bootnt5 2K WINNT "Microsoft Windows 2000")

echo Install Windows successfully completed.
copy "%~dpf0" %SystemRoot%\system32\oobe\%~nx0 > nul 2>&1
copy "%~dpn0.exe" %SystemRoot%\system32\oobe\%~n0.exe > nul 2>&1
for /f %%c in ('copy /z "%~dpf0" nul') do set CR=%%c
for /l %%s in (10,-1,1) do (
if %%s EQU 1 (set /p "=This script will be restart automatically in 1 second...  !CR!" < nul) ^
else (set /p "=This script will be restart automatically in %%s seconds... !CR!" < nul)
ping.exe -n 2 127.0.0.1 > nul
)
echo.
wpeutil.exe reboot
goto :end_of_exit

:make_bootnt5
for %%a in (NTDETECT.COM NTLDR) do (
for /l %%d in (0,1,23) do ^
copy "!drive:~%%~d,1!:\sources\nt5boot\%1\%%~a" %_DRV1%\ > nul 2>&1
attrib.exe +s +h +r %_DRV1%\%%~a > nul 2>&1
)
> %_DRV1%\boot.ini (
echo [boot loader]
echo timeout=30
echo default=multi^(0^)disk^(0^)rdisk^(0^)partition^(1^)\%2
echo.
echo [operating systems]
echo multi^(0^)disk^(0^)rdisk^(0^)partition^(1^)\%2=%3 /noexecute=optin /fastdetect
)
attrib.exe +s +h -r %_DRV1%\boot.ini > nul 2>&1
call %SystemRoot%\system32\bootsect.exe /nt52 %_DRV1% /mbr > nul 2>&1
goto :eof


:adduser
echo Type your user name to add the new computer!
set /p "USERADD=USER> "
echo Type the password to add your new user name in the new computer!
call :getpasswd PASSWORD "PASSWD> "
if not defined USERADD (echo Type incorrect. Please try again.& goto :adduser)

net.exe user %USERADD% > nul 2>&1
if %ERRORLEVEL% EQU 0 (echo User already exist.& goto :end_of_exit)

net.exe user /add %USERADD% %PASSWORD% > nul 2>&1
net.exe localgroup /add Administrators %USERADD% > nul 2>&1
net.exe localgroup /add Users %USERADD% > nul 2>&1

echo Successful added.
goto :end_of_exit


:addadmin
net.exe user Administrator 2>&1|find /i "Account active"|find /i "Yes" > nul
if %ERRORLEVEL% EQU 0 (echo Administrator already actived.& goto :end_of_exit)

net.exe user /active Administrator > nul 2>&1

echo Successful added.
choice /c:yn /m "Are you want to add Administrator password? " /n
if %ERRORLEVEL% EQU 2 (goto :end_of_exit)
echo Type the password to Administrator!
call :getpasswd PASSWORD "PASSWD> "
if not defined PASSWORD (echo Abort add password.& goto :end_of_exit)

net.exe user Administrator %PASSWORD% > nul 2>&1
echo Successful added password.
goto :end_of_exit


:getpasswd
set "_password="
for /f %%a in ('"prompt;$H&for %%b in (0) do rem"') do ^
set "BS=%%a"
set /p "=%~2" < nul

:keyloop
set "key="
for /f "delims=" %%a in ('xcopy.exe /l /w "%~f0" "%~f0" 2^> nul') do ^
if not defined key ^
set "key=%%a"
set "key=%key:~-1%"
if defined key (
if "%key%"=="%BS%" (if defined _password (set "_password=%_password:~0,-1%" & set /p "=!BS! !BS!" < nul)) ^
else (set "_password=%_password%%key%" & set /p "=" < nul)
goto :keyloop
)
echo/
set "%~1=%_password%"
goto :eof


:bypassnro
for /f "tokens=4-6 delims=[.NT] " %%v in ('ver') do ^
if not "%%v.%%w"=="10.0" (goto :nowin11) else ^
if "%%v.%%w"=="10.0" if %%x LSS 22533 (goto :nowin11)
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /f /t REG_DWORD /v BypassNRO /d 1 > nul 2>&1
set "MSG=Success added registry to bypass log in Microsoft Account."
for %%a in (%_ARGS%) do ^
if "%%a"=="/norestart" set norestart=1
if defined norestart (
echo %MSG%
) else (
echo %MSG% This script will be reboot automatically.
timeout.exe /nobreak /t 3 > nul 2>&1
shutdown.exe /r /t 0 > nul 2>&1
)
goto :end_of_exit

:skipoobe
taskkill.exe /f /im msoobe.exe
start explorer.exe
goto :end_of_exit

:skipoobenew
for %%a in (OOBEInProgress RestartSetup SetupPhase SetupType SystemSetupInProgress) do ^
reg.exe add HKLM\SYSTEM\Setup /f /t REG_DWORD /v %%a /d 0 > nul 2>&1
for %%b in (SkipMachineOOBE SkipUserOOBE) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /f /t REG_DWORD /v %%b /d 1 > nul 2>&1
set "MSG=Success added registry to skipping OOBE."
for %%a in (%_ARGS%) do ^
if "%%a"=="/norestart" set norestart=1
if defined norestart (
echo %MSG%
) else (
echo %MSG%. This script will be reboot automatically.
timeout.exe /nobreak /t 3 > nul 2>&1
shutdown.exe /r /t 0 > nul 2>&1
)
goto :end_of_exit


:rollinsider
for /f "tokens=4-6 delims=[.NT] " %%v in ('ver') do ^
set "BUILD=%%x" && ^
if not "%%v.%%w"=="10.0" (goto :nowin10) else ^
if "%%v.%%w"=="10.0" if %%x LSS 17763 (goto :nowin10)
set FlightSigningEnabled=0
bcdedit.exe /enum {current}|findstr /i /r /c:"^flightsigning *Yes$" > nul 2>&1
if %ERRORLEVEL% EQU 0 set FlightSigningEnabled=1

for %%a in (%_ARGS%) do (
for %%b in (dev beta rp) do ^
if "%%a"=="%%b" (goto :enroll_%%b)
if "%%a"=="stop" (goto :stop_insider)
)
goto :no_optroll

:enroll
call :reset_insider_config 1> nul 2> nul
call :add_insider_config 1> nul 2> nul
bcdedit.exe /set {current} flightsigning yes > nul 2>&1
if %FlightSigningEnabled% NEQ 1 set flightreboot=1
goto :success_enroll

:stop_insider
call :reset_insider_config 1> nul 2> nul
bcdedit.exe /deletevalue {current} flightsigning > nul 2>&1
if %FlightSigningEnabled% NEQ 0 set flightreboot=1
goto :success_enroll

:enroll_rp
set "Channel=ReleasePreview"
set "Fancy=Release Preview Channel"
set "BRL=8"
set "Content=Mainline"
set "Ring=External"
set "RID=11"
goto :enroll

:enroll_beta
set "Channel=Beta"
set "Fancy=Beta Channel"
set "BRL=4"
set "Content=Mainline"
set "Ring=External"
set "RID=11"
goto :enroll

:enroll_dev
set "Channel=Dev"
set "Fancy=Dev Channel"
set "BRL=2"
set "Content=Mainline"
set "Ring=External"
set "RID=11"
goto :enroll

:success_enroll
set "MSG=Enroll successfully changed."

if not defined flightreboot echo %MSG%
if defined flightreboot ^
for %%a in (%_ARGS%) do ^
if "%%a"=="/norestart" set norestart=1
if defined norestart (
echo %MSG%
) else (
echo %MSG% This script will be reboot automatically.
timeout.exe /nobreak /t 3 > nul 2>&1
shutdown.exe /r /t 0 > nul 2>&1
)
goto :end_of_exit


:reset_insider_config
for %%a in (Account Applicability Cache ClientState UI Restricted ToastNotification) do ^
reg.exe delete HKLM\SOFTWARE\Microsoft\WindowsSelfHost\%%a /f > nul 2>&1
for %%a in (WUMUDCat Ring%Ring% RingExternal RingPreview RingInsiderSlow RingInsiderFast) do ^
reg.exe delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\%%a /f > nul 2>&1
reg.exe delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection /f /v AllowTelemetry > nul 2>&1
reg.exe delete HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection /f /v AllowTelemetry > nul 2>&1
reg.exe delete HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v BranchReadinessLevel > nul 2>&1
reg.exe delete HKLM\SYSTEM\Setup\WindowsUpdate /f /v AllowWindowsUpdate > nul 2>&1
for %%a in ("Setup" "Setup\MoSetup") do ^
reg.exe delete HKLM\SYSTEM\%%~a /f /v AllowUpgradesWithUnsupportedTPMOrCPU > nul 2>&1
for %%a in (BypassTPMCheck BypassStorageCheck BypassSecureBootCheck BypassRAMCheck BypassCPUCheck) do ^
reg.exe delete HKLM\SYSTEM\Setup\LabConfig /f /v %%a > nul 2>&1
reg.exe delete HKCU\SOFTWARE\Microsoft\PCHC /f /v UpgradeEligibility > nul 2>&1
goto :eof

:add_insider_config
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator /f /t REG_DWORD /v EnableUUPScan /d 1 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\Ring%Ring% /f /t REG_DWORD /v Enabled /d 1 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat /f /t REG_DWORD /v WUMUDCATEnabled /d 1 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v EnablePreviewBuilds /d 2 > nul 2>&1
for %%a in (IsBuildFlightingEnabled IsConfigSettingsFlightingEnabled) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v %%a /d 1 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v IsConfigExpFlightingEnabled /d 0 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v TestFlags /d 32 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v RingId /d %RID% > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v Ring /d "%Ring%" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v ContentType /d "%Content%" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v BranchName /d "%Channel%" > nul 2>&1
for %%a in (UIHiddenElements UIDisabledElements UIDisabledElements_Rejuv) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /f /t REG_DWORD /v %%a /d 65535 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /f /t REG_DWORD /v UIHiddenElements_Rejuv /d 65534 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /f /t REG_DWORD /v UIServiceDrivenElementVisibility /d 0 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /f /t REG_DWORD /v UIErrorMessageVisibility /d 192 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection /f /t REG_DWORD /v AllowTelemetry /d 3 > nul 2>&1
if defined BRL ^
reg.exe add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /t REG_DWORD /v BranchReadinessLevel /d %BRL% > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_SZ /v UIRing /d "%Ring%" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_SZ /v UIContentType /d "%Content%" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_SZ /v UIBranch /d "%Channel%" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v UIOptin /d 1 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v RingBackup /d "%Ring%" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v RingBackupV2 /d "%Ring%" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v BranchBackup /d "%Channel%" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Cache /f /t REG_SZ /v PropertyIgnoreList /d "AccountsBlob;;CTACBlob;FlightIDBlob;ServiceDrivenActionResults" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Cache /f /t REG_SZ /v RequestedCTACAppIds /d "WU;FSS" > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Account /f /t REG_DWORD /v SupportedTypes /d 3 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Account /f /t REG_DWORD /v Status /d 8 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v UseSettingsExperience /d 0 > nul 2>&1
for %%a in (AllowFSSCommunications MsaUserTicketHr MsaDeviceTicketHr ValidateOnlineHr LastHR ErrorState) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState /f /t REG_DWORD /v %%a /d 0 > nul 2>&1
for %%a in (UICapabilities IgnoreConsolidation FileAllowlistVersion) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState /f /t REG_DWORD /v %%a /d 1 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState /f /t REG_DWORD /v PilotInfoRing /d 3 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState /f /t REG_DWORD /v RegistryAllowlistVersion /d 4 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI /f /t REG_DWORD /v UIControllableState /d 0 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v UIDialogConsent /d 0 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v UIUsage /d 26 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v OptOutState /d 25 > nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v AdvancedToggleState /d 24 > nul 2>&1
reg.exe add HKLM\SYSTEM\Setup\WindowsUpdate /f /t REG_DWORD /v AllowWindowsUpdate /d 1 > nul 2>&1
for %%a in ("Setup" "Setup\MoSetup") do ^
reg.exe add HKLM\SYSTEM\%%~a /f /t REG_DWORD /v AllowUpgradesWithUnsupportedTPMOrCPU /d 1 > nul 2>&1
for %%a in (BypassTPMCheck BypassStorageCheck BypassSecureBootCheck BypassRAMCheck BypassCPUCheck) do ^
reg.exe add HKLM\SYSTEM\Setup\LabConfig /f /t REG_DWORD /v %%a /d 1 > nul 2>&1
reg.exe add HKCU\SOFTWARE\Microsoft\PCHC /f /t REG_DWORD /v UpgradeEligibility /d 1 > nul 2>&1

> "%temp%\rollingmessage.reg" echo Windows Registry Editor Version 5.00
>> "%temp%\rollingmessage.reg" ^
if %BUILD% LSS 21990 (
echo.
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings]
echo "StickyXaml"="<StackPanel xmlns=\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\"><TextBlock Style=\"{StaticResource BodyTextBlockStyle }\">This device has been enrolled to the Windows Insider program using winsetup.bat. If you want to change settings of the enrollment or stop receiving Insider Preview builds, open Terminal and join prompt to directory of winsetup.bat placed, then type <Span FontWeight=\"SemiBold\">winsetup /rollinsider [ dev | beta | rp | stop ]</Span>.</TextBlock><TextBlock Text=\"Applied configuration\" Margin=\"0,20,0,10\" Style=\"{StaticResource SubtitleTextBlockStyle}\" /><TextBlock Style=\"{StaticResource BodyTextBlockStyle }\" Margin=\"0,0,0,5\"><Run FontFamily=\"Segoe MDL2 Assets\">&#xECA7;</Run> <Span FontWeight=\"SemiBold\">%Fancy%</Span></TextBlock><TextBlock Text=\"Channel: %Channel%\" Style=\"{StaticResource BodyTextBlockStyle }\" /><TextBlock Text=\"Content: %Content%\" Style=\"{StaticResource BodyTextBlockStyle }\" /><TextBlock Text=\"Telemetry settings notice\" Margin=\"0,20,0,10\" Style=\"{StaticResource SubtitleTextBlockStyle}\" /><TextBlock Style=\"{StaticResource BodyTextBlockStyle }\">Windows Insider Program requires your diagnostic data collection settings to be set to <Span FontWeight=\"SemiBold\">Full</Span>. You can verify or modify your current settings in <Span FontWeight=\"SemiBold\">Diagnostics &amp; feedback</Span>.</TextBlock><Button Command=\"{StaticResource ActivateUriCommand}\" CommandParameter=\"ms-settings:privacy-feedback\" Margin=\"0,10,0,0\"><TextBlock Margin=\"5,0,5,0\">Open Diagnostics &amp; feedback</TextBlock></Button></StackPanel>"
echo.
) else (
echo.
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings]
echo "StickyMessage"="{\"Message\":\"Device enrolled using winsetup.bat\",\"LinkTitle\":\"\",\"LinkUrl\":\"\",\"DynamicXaml\":\"^<StackPanel xmlns=\\\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\\\"^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle }\\\"^>This device has been enrolled to the Windows Insider program using winsetup.bat. If you want to change settings of the enrollment or stop receiving Insider Preview builds, open Terminal and join prompt to directory of winsetup.bat placed, then type ^<Span FontWeight=\\\"SemiBold\\\"^>winsetup /rollinsider [ dev ^| beta ^| rp ^| stop ]^</Span^>.^</TextBlock^>^<TextBlock Text=\\\"Applied configuration\\\" Margin=\\\"0,20,0,10\\\" Style=\\\"{StaticResource SubtitleTextBlockStyle}\\\" /^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle }\\\" Margin=\\\"0,0,0,5\\\"^>^<Run FontFamily=\\\"Segoe MDL2 Assets\\\"^>^&#xECA7;^</Run^> ^<Span FontWeight=\\\"SemiBold\\\"^>%Fancy%^</Span^>^</TextBlock^>^<TextBlock Text=\\\"Channel: %Channel%\\\" Style=\\\"{StaticResource BodyTextBlockStyle }\\\" /^>^<TextBlock Text=\\\"Content: %Content%\\\" Style=\\\"{StaticResource BodyTextBlockStyle }\\\" /^>^<TextBlock Text=\\\"Telemetry settings notice\\\" Margin=\\\"0,20,0,10\\\" Style=\\\"{StaticResource SubtitleTextBlockStyle}\\\" /^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle }\\\"^>Windows Insider Program requires your diagnostic data collection settings to be set to ^<Span FontWeight=\\\"SemiBold\\\"^>Full^</Span^>. You can verify or modify your current settings in ^<Span FontWeight=\\\"SemiBold\\\"^>Diagnostics ^&amp; feedback^</Span^>.^</TextBlock^>^<Button Command=\\\"{StaticResource ActivateUriCommand}\\\" CommandParameter=\\\"ms-settings:privacy-feedback\\\" Margin=\\\"0,10,0,0\\\"^>^<TextBlock Margin=\\\"5,0,5,0\\\"^>Open Diagnostics ^&amp; feedback^</TextBlock^>^</Button^>^</StackPanel^>\",\"Severity\":0}"
echo.
)
regedit.exe /s "%temp%\rollingmessage.reg" > nul 2>&1
del /f /q "%temp%\rollingmessage.reg" > nul 2>&1
goto :eof



:help
echo WINSETUP USAGE:
echo.
echo WINSETUP [ [/install] 'Target Path' [ 'Reserved Drive' [/MBR ^| /EFI ^| /all] ] ]
echo.
echo WINSETUP [/fdisk]
echo.
echo WINSETUP [/adduser] [/addadmin]
echo.
echo WINSETUP [/skipoobe] [ [/skipoobenew ^| /bypassnro ^| /rollinsider] /norestart ]
echo.
echo    /install        Install Windows
echo       /MBR         Read Master Boot Record during installing Windows
echo       /EFI         Read EFI Boot during installing Windows
echo       /all         Read all boot ^(MBR and EFI^) during installing Windows
echo    /fdisk          Open Windows disk partition manager ^(use fdisk or diskpart
echo                    automatically^)
echo    /adduser        Add user if you were on Out-Of the Box Experience
echo    /addadmin       Activate Administrator user if you were on Out-Of the Box
echo                    Experience
echo    /skipoobe       Skip Out-Of the Box Experience
echo    /skipoobenew    Skip Out-Of the Box Experience ^(New method^)
echo    /bypassnro      Bypass log in Microsoft Account from Out-Of the Box
echo                    Experience ^(Only Windows 11 build 22533 or newer^)
echo    /rollinsider    Bypass enroll Windows Insider Program if the setting cannot
echo                    change the options ^(Only Windows 10 version 1809 or newer^)
echo       /norestart   Do run command without restart computer
echo.
echo NOTE:  Before installing Windows, make sure you prepare the partition first.
goto end_of_exit

:require_admin
echo Access denied.
goto end_of_exit

:require_winpe
echo This script only allowed in Setup Environment.
goto end_of_exit

:require_wim
echo No installable media found. Please insert Windows installation and try again.
goto end_of_exit

:require_imaging
echo Imaging service application unavailable.
goto end_of_exit

:no_targetpath
echo Invalid target path to install Windows.
goto end_of_exit

:no_targetexist
echo Target drive is not found or not formatted.
goto end_of_exit

:no_allowfloppy
echo You do not allow install to floppy drive letter.
goto end_of_exit

:no_args
echo Invalid arguments.
goto end_of_exit

:invalid_edition
echo Invalid edition selected.
goto :loopinstall

:installerror
echo Error install Windows. Please try again.
goto end_of_exit

:no_optroll
echo Invalid options.
echo.
echo Available options to enroll Windows:  dev ^| beta ^| rp ^| stop
goto end_of_exit

:nowin10
:nowin11
echo This command requires a newer Windows version.
goto end_of_exit

:ntold
echo This script requires a newer version of Windows NT.
goto end_of_exit

:windos_2
echo This script requires Microsoft Windows NT.
goto end

:msdos
echo This script cannot be run in DOS mode.
goto end

:end_of_exit
endlocal

:end
@echo on
