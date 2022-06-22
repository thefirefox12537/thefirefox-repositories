@ echo off

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
REM  Program requirement:   DISM.EXE IMAGEX.EXE WIMLIB-IMAGEX.EXE NET.EXE

REM  VersionInfo:
REM
REM    File version:      10,0,22000,1
REM    Product Version:   10,0,22000,1
REM
REM    CompanyName:       Microsoft Corporation
REM    FileDescription:   Windows Setup
REM    FileVersion:       10.0.22000.1 (WinBuild.160101.0800)
REM    InternalName:      winsetup
REM    LegalCopyright:    © Microsoft Corporation. All rights reserved.
REM    OriginalFileName:  WINSETUP.BAT
REM    ProductName:       Microsoft® Windows® Operating System
REM    ProductVersion:    10.0.22000.1


:start
if %OS%!==Windows_NT! goto runwinnt

:rundosbox
ver|find "DOSBox" >nul
if not errorlevel 1 goto msdos

:runos_2
ver|find "Operating System/2" >nul
if not errorlevel 1 goto windos_2

:runwindos
if exist %windir%\..\msdos.sys find "WinDir" %windir%\..\msdos.sys >nul
if not errorlevel 1 goto windos_2
goto msdos

:runwinnt
@ break on
@ setlocal & set OLD_WINNT=0

for %%v in (Daytona Cairo Hydra Neptune NT) do ^
ver|find "%%v" >nul & ^
if not errorlevel 1 set OLD_WINNT=1

if %OLD_WINNT%!==1! goto ntold
if %OLD_WINNT%!==0! setlocal enableextensions enabledelayedexpansion

for /f "tokens=4-6 delims=[.NT] " %%v in ('ver') do (
for %%a in (5.00 5.10 5.1 5.2 5.3 5.4) do (
if /i "%%w.%%x"=="%%a" (goto ntold)
if /i "%%v.%%w"=="%%a" (goto ntold)
))

set _ARGS=%*
set _FILE=%~dpf0
set _PARAM=%~1
set _DRV1=%~2
set _DRV2=%~3
set _TYPE=%~4
set _OPTS= ^
fdisk install upgrade adduser addadmin ^
bypassnro skipoobe skipoobenew rollinsider

for %%a in (ARGS PARAM DRV1 DRV2 TYPE) do ^
if defined _%%a set _%%a=!_%%a:"=!

for %%a in (%_ARGS%) do ^
for %%b in (%_OPTS%) do ^
if /i "%%a"=="/%%~b" (set stepgoto=%%~b)
if not defined stepgoto (goto :help)

for %%d in ("%SystemRoot%\system32\config\default") do ^
if /i not "%SystemRoot:~0,2%"=="X:" (icacls.exe %%~dpd\system >nul 2>&1) ^
else (bcdedit.exe /store %%~dpd\bcd-template >nul 2>&1)
if %ERRORLEVEL% NEQ 0 goto :require_admin

set drive= A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
set alpha= A B C D E F G H I J K L M N O P Q R S T U V W Y Z 0

for %%d in (%drive%) do ^
for %%p in (DRV1 DRV2) do ^
set _%%p=!_%%p:%%d=%%d!

if defined stepgoto ^
goto :%stepgoto%
goto :help


:fdisk
for %%a in (%PATHEXT:.=%) do ^
for %%f in (fdisk.%%a) do ^
if exist "%%~$PATH:f" (set diskmgmt=%%f) else ^
if exist "%%~dpff" (set diskmgmt=%%f)

if not defined diskmgmt ^
for %%f in (diskpart.exe) do ^
if exist "%%~$PATH:f" (set diskmgmt=%%f)

@ call %diskmgmt%
@ echo off & goto end_of_exit


:install
if /i not "%SystemRoot:~0,2%"=="X:" (goto :require_winpe)
if /i not "%_FILE:~0,2%"=="X:" (goto :media_redirect)
for %%a in ("Setup" "Setup\MoSetup") do ^
reg.exe add HKLM\SYSTEM\%%~a /f /t REG_DWORD /v AllowUpgradesWithUnsupportedTPMOrCPU /d 1 >nul 2>&1
for %%a in ("Setup" "SYSTEM\Setup") do ^
for %%b in (BypassTPMCheck BypassStorageCheck BypassSecureBootCheck BypassRAMCheck BypassCPUCheck) do ^
reg.exe add HKLM\%%~a\LabConfig /f /t REG_DWORD /v %%b /d 1 >nul 2>&1
::WIMLIB-IMAGEX
for %%i in ("wimlib-imagex.exe") do ^
for %%a in ("." "sources" "sources\wimlib" "sources\wimlib-imagex") do ^
for %%d in (%drive%) do ^
if exist "%%~d:\%%~a\%%~i" (set "wimlibcd=%%~d:\%%~a\%%~i")
for %%i in ("wimlib-imagex.exe") do ^
for %%f in (
"%wimlibcd%" "%%~$PATH:i" "%~dp0\%%~i"
"%~dp0\wimlib\%%~i" "%~dp0\wimlib-imagex\%%~i"
"%SystemRoot%\wimlib\%%~i" "%SystemRoot%\wimlib-imagex\%%~i"
"%SystemDrive%\wimlib\%%~i" "%SystemDrive%\wimlib-imagex\%%~i"
) do ^
if exist "%%~f" if exist "%%~dpf\libwim*.dll" (set "wimlib=%%~f")
if defined wimlib (set "imaging=wimlib" & goto :next1)
::IMAGEX
for %%i in ("imagex.exe") do ^
for %%d in (%drive%) do ^
for %%a in ("." "sources") do ^
if exist "%%~d:\%%~a\%%~i" (set "imagexcd=%%~d:\%%~a\%%~i")
for %%i in ("imagex.exe") do ^
for %%f in ("%imagexcd%" "%%~$PATH:i" "%~dp0\%%~i") do ^
if exist "%%~f" (set "imagex=%%~f")
if defined imagex (set "imaging=imagex" & goto :next1)
::DISM
for %%d in ("dism.exe") do ^
if exist "%%~$PATH:d" ^
for /f "usebackq tokens=2-3 delims=:. " %%v in (`call "%%~$PATH:d"^|find /i "Version:"`) do ^
if /i %%v EQU 6 (if /i %%w LSS 2 (goto :ntold)) else ^
if /i %%v LSS 6 (goto :ntold) ^
else (set "dism=%%~$PATH:d")
if defined dism (set "imaging=dism" & goto :next1)

:next1
if /i %2!==! (goto :no_targetpath) else ^
if /i "%_DRV1:~0,1%"=="A" (goto :no_allowfloppy) else ^
if /i "%_DRV1:~0,1%"=="B" (goto :no_allowfloppy) else ^
if not exist %_DRV1% (goto :no_targetexist)
if /i %3!==! (goto :no_args)

for %%a in ("sources\install") do ^
for %%d in (%drive%) do ^
if exist "%%~d:\%%~a.wim" (
set "opt=imagefile"
set "installsrc=%%~d:\sources\install.wim"
) else ^
if exist "%%~d:\%%~a.swm" (
set "opt=imagefile"
set "installsrc=%%~d:\sources\install.swm"
if /i "%imaging%"=="wimlib" set "swm=--ref=^"%%~d:\sources\install*.swm^""
if /i "%imaging%"=="imagex" set "swm=/ref ^"%%~d:\sources\install*.swm^""
if /i "%imaging%"=="dism" set "swm=/swmfile:^"%%~d:\sources\install*.swm^""
) else ^
if exist "%%~d:\%%~a.esd" (
set "opt=imagefile"
set "installsrc=%%~d:\sources\install.esd"
)

if not defined opt (goto :require_wim)
if defined imaging (goto :next2)
goto :require_imaging

:next2
for %%a in (%_ARGS%) do ^
if /i "%%a"=="/scandisk" (
echo Scanning drive %_DRV1% before installing Windows...
call %SystemRoot%\system32\chkdsk.exe %_DRV1% >nul 2>&1
)
set "SPACE= "
echo Type the available index number to install Windows.
:loopinstall
echo.
echo Install source: %installsrc%
echo Available edition:
if /i "%imaging%"=="wimlib" ^
for /f "tokens=3* delims=: " %%a in ('call "%wimlib%" info "%installsrc%"^|find /i "Display Name:"') do ^
echo.  %%~a %%~b >>"%tmp%\%~n0.txt"
if /i "%imaging%"=="imagex" ^
for /f "tokens=3* delims=><" %%a in ('call "%imagex%" /info "%installsrc%"^|find /i "<NAME>"') do ^
if /i "%%~a"=="%SPACE%" (echo.  NOT IDENTIFIED EDITION >>"%tmp%\%~n0.txt") ^
else (echo  %%~a >>"%tmp%\%~n0.txt")
if /i "%imaging%"=="dism" ^
for /f "tokens=2* delims=:" %%a in ('call "%dism%" /get-imageinfo /%opt%:"%installsrc%"^|find /i "Name"') do ^
if "%%~a"=="%SPACE%" (echo.  NOT IDENTIFIED EDITION >>"%tmp%\%~n0.txt") ^
else (echo  %%~a >>"%tmp%\%~n0.txt")
if not exist "%tmp%\%~n0.txt" echo [ERROR]  Not shown edition name of image. You must get image information manually.
type "%tmp%\%~n0.txt" 2>nul|find /n "%SPACE%" && del /f /q "%tmp%\%~n0.txt" >nul 2>&1
echo.
:loopindex
set /p "INDEX=INDEX> "
if not defined INDEX (goto :loopindex)
if /i "%INDEX%"=="%SPACE%" (goto :loopindex)
for /l %%s in (1,2,51) do ^
if /i %INDEX%?==!alpha:~%%~s,1!? (goto :invalid_edition)
if /i %INDEX%?==X? (echo Exitting...& goto :end_of_exit)

echo Expanding Windows...
if /i "%imaging%"=="wimlib" (call "%wimlib%" apply "%installsrc%" %INDEX% %_DRV1%\ %swm%)
if /i "%imaging%"=="imagex" (call "%imagex%" /apply "%installsrc%" %swm% %INDEX% %_DRV1%\)
if /i "%imaging%"=="dism" (call "%dism%" /apply-image /%opt%:"%installsrc%" %swm% /index:%INDEX% /applydir:%_DRV1%\)
if %ERRORLEVEL% NEQ 0 (goto :installerror)
if not exist %_DRV1%\Windows (goto :installerror)

:buildbcd
echo Cleaning old Boot Configuration Data store and information log...
for %%i in (
autoexec.* command.* config.* ibmbio.* ibmdos.* io.* msdos.*
bootsect.* bootmgr.* bootwin.* BOOTNXT BOOTTGT GRLDR
boot.ini NTDETECT.COM NTLDR
*.ini *.txt *.log *.sys *.bin *.1st *.bat *.cmd
) do (
del /f /asr /q %_DRV1%\%%~i
del /f /asr /q %_DRV2%\%%~i
del /f /ashr /q %_DRV1%\%%~i
del /f /ashr /q %_DRV2%\%%~i
attrib.exe -s -h -r %_DRV1%\%%~i
attrib.exe -s -h -r %_DRV2%\%%~i
del /f /q %_DRV1%\%%~i >nul 2>&1
del /f /q %_DRV2%\%%~i >nul 2>&1
) >nul 2>&1
for %%d in (boot efi recovery grub) do (
rmdir /s /q %_DRV1%\%%~d
rmdir /s /q %_DRV2%\%%~d
) >nul 2>&1

echo Rebuilding Boot Configuration Data store...
for %%a in (%_ARGS%) do (
if /i "%%a"=="/all" (set "BOOTDRV=%_DRV2%" & call :make_bootefi & call :make_bootsect) >nul 2>&1
for %%s in (uefi efi) do ^
if /i "%%a"=="/%%s" (set "BOOTDRV=%_DRV2%" & call :make_bootefi) >nul 2>&1
for %%s in (bios mbr) do ^
if /i "%%a"=="/%%s" (
if defined _TYPE (set "BOOTDRV=%_DRV2%" & call :make_bootsect) >nul 2>&1 ^
else (set "BOOTDRV=%_DRV1%" & call :make_bootsect) >nul 2>&1
))

echo Install Windows successfully completed.
copy /y "%~dpf0" %_DRV1%\Windows\system32\oobe\%~nx0 >nul 2>&1
copy /y "%~dpn0.exe" %_DRV1%\Windows\system32\oobe\%~n0.exe >nul 2>&1
for /f %%c in ('copy /z "%~dpf0" nul') do set CR=%%c
for /l %%s in (10,-1,1) do (
if %%s EQU 1 (set /p "=This script will be restart automatically in 1 second...  !CR!" <nul) ^
else (set /p "=This script will be restart automatically in %%s seconds... !CR!" <nul)
ping.exe -n 2 127.0.0.1 >nul
)
echo.
wpeutil.exe reboot
goto :end_of_exit

:media_redirect
copy /y "%~dpf0" "%tmp%\%~nx0" >nul 2>&1
copy /y "%~dpn0.exe" "%tmp%\%~n0.exe" >nul 2>&1
@ cd /d "%tmp%" & %~n0 %*
@ cd /d "%~dp0" & for %%a in ("%tmp%\%~nx0" "%tmp%\%~n0.exe") do @del /f /q "%%~a" >nul 2>&1
@ echo off & goto :end_of_exit

:make_bootefi
call %SystemRoot%\system32\bcdboot.exe %_DRV1%\Windows /s %BOOTDRV% /f UEFI
goto :eof

:make_bootsect
call %SystemRoot%\system32\bcdboot.exe %_DRV1%\Windows /s %BOOTDRV% /f BIOS
call %SystemRoot%\system32\bootsect.exe /nt60 %BOOTDRV% /mbr /force
goto :eof


:upgrade
if /i "%SystemRoot:~0,2%"=="X:" (goto :require_wininstall)
if exist "%SystemDrive%\$WINDOWS.~BT\sources" (set "setupdir=%SystemDrive%\$WINDOWS.~BT\sources") else ^
for %%d in (%drive%) do ^
if exist "%%~d:\sources" (set "setupdir=%%~d:\sources")
if not defined setupdir goto :no_upgrade

for %%a in (%_ARGS%) do ^
if /i "%%a"=="/bypasstpm" set upgrade=bypasstpm
for %%s in ("setup.exe" "SetupApp.exe" "SetupCore.exe" "SetupHost.exe" "SetupPrep.exe") do ^
taskkill.exe /f /im %%~s >nul 2>&1

for %%r in ("%setupdir%\appraiserres.dll") do ^
if exist "%%~r" (if /i %%~zr?==0? (set setuppatched=1) else (set "patchfile=%%~r"))

if /i not "%upgrade%"=="bypasstpm" ^
if not defined setuppatched (
findstr /r "P.r.o.d.u.c.t.V.e.r.s.i.o.n...1.0.\..0.\..2.[25]" "%patchfile%" >nul && ^
attrib "%patchfile%" 2>&1|findstr /r "R." >nul || (
echo Patching appraiserres.dll file...
ren "%patchfile%" appraiserres.old >nul 2>&1
>"%patchfile%" echo.
)
if not exist "%setupdir%\appraiserres.old" goto :media_readonly
)

if not exist "%setupdir%\EI.cfg" (
echo Patching EI.cfg file...
>"%setupdir%\EI.cfg" echo [Channel]
>>"%setupdir%\EI.cfg" echo _Default
) 2>nul

if not exist "%setupdir%\SetupHost.exe" (
echo Making hard link SetupHost.exe file...
mklink /h "%setupdir%\SetupCore.exe" "%setupdir%\SetupCore.exe" >nul 2>&1
)

:do_upgrade
if /i "%upgrade%"=="bypasstpm" goto :do_upgrade_bypasstpm
for %%s in ("setup.exe" "SetupCore.exe" "SetupHost.exe") do ^
if exist "%setupdir%\%%~s" (
echo Upgrading Windows...
set "setup=%%~s" & goto :upgrun
)
goto :no_upgrade

:do_upgrade_bypasstpm
if exist "%setupdir%\SetupCore.exe" (
echo Upgrading Windows with bypass TPM check...
set "setup=SetupCore.exe"
) else (
goto :no_upgrade
)
set /a restart_application=0x800705BB
set /a incorrect_parameter=0x80070057
set /a launch_option_error=0xc190010a
set parameter=/Product Server /Compat IgnoreWarning /MigrateDrivers All /Telemetry Disable
set tryparameter=/Compat IgnoreWarning /MigrateDrivers All /Telemetry Disable

:upgrun
call "%setupdir%\%setup%" %parameter%
if %errorlevel%==%restart_application% ^
call "%setupdir%\%setup%" %tryparameter%
goto end_of_exit


:adduser
if /i "%SystemRoot:~0,2%"=="X:" (goto :require_wininstall)
echo Type your user name to add the new computer!
set /p "USERADD=USER> "
echo Type the password to add your new user name in the new computer!
call :getpasswd PASSWORD "PASSWD> "
if not defined USERADD (echo Type incorrect. Please try again.& goto :adduser)

net.exe user %USERADD% >nul 2>&1
if %ERRORLEVEL% EQU 0 (echo User already exist.& goto :end_of_exit)

net.exe user /add %USERADD% %PASSWORD% >nul 2>&1
net.exe localgroup /add Administrators %USERADD% >nul 2>&1
net.exe localgroup /add Users %USERADD% >nul 2>&1

echo Successful added.
goto :end_of_exit


:addadmin
if /i "%SystemRoot:~0,2%"=="X:" (goto :require_wininstall)
net.exe user Administrator 2>&1|findstr /i /r /c:"Account active"|findstr /i /r /c:"Yes" >nul
if %ERRORLEVEL% EQU 0 (echo Administrator already actived.& goto :end_of_exit)

net.exe user /active Administrator >nul 2>&1

echo Successful added.
choice /c:yn /m "Are you want to add Administrator password? " /n
if %ERRORLEVEL% EQU 2 (goto :end_of_exit)
echo Type the password to Administrator!
call :getpasswd PASSWORD "PASSWD> "
if not defined PASSWORD (echo Abort add password.& goto :end_of_exit)

net.exe user Administrator %PASSWORD% >nul 2>&1
echo Successful added password.
goto :end_of_exit


:getpasswd
set "_password="
for /f %%a in ('"prompt;$H&for %%b in (0) do rem"') do ^
set "BS=%%a"
set /p "=%~2" <nul

:keyloop
set "key="
for /f "delims=" %%a in ('xcopy.exe /l /w "%~f0" "%~f0" 2^>nul') do ^
if not defined key ^
set "key=%%a"
set "key=%key:~-1%"
if defined key (
if "%key%"=="%BS%" (if defined _password (set "_password=%_password:~0,-1%" & set /p "=!BS! !BS!" <nul)) ^
else (set "_password=%_password%%key%" & set /p "=" <nul)
goto :keyloop
)
echo/
set "%~1=%_password%"
goto :eof


:bypassnro
if /i "%SystemRoot:~0,2%"=="X:" (goto :require_wininstall)
for /f "tokens=4-6 delims=[.NT] " %%v in ('ver') do ^
if /i not "%%v.%%w"=="10.0" (goto :nowin11) else ^
if /i "%%v.%%w"=="10.0" if /i %%x LSS 22533 (goto :nowin11)
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /f /t REG_DWORD /v BypassNRO /d 1 >nul 2>&1
set "MSG=Success added registry to bypass log in Microsoft Account."
for %%a in (%_ARGS%) do ^
if /i "%%a"=="/norestart" set norestart=1
if defined norestart (
echo %MSG%
) else (
echo %MSG% This script will be reboot automatically.
timeout.exe /nobreak /t 3 >nul 2>&1
shutdown.exe /r /t 0 >nul 2>&1
)
goto :end_of_exit

:skipoobe
if /i "%SystemRoot:~0,2%"=="X:" (goto :require_wininstall)
taskkill.exe /f /im msoobe.exe
start explorer.exe
goto :end_of_exit

:skipoobenew
if /i "%SystemRoot:~0,2%"=="X:" (goto :require_wininstall)
for %%a in (OOBEInProgress RestartSetup SetupPhase SetupType SystemSetupInProgress) do ^
reg.exe add HKLM\SYSTEM\Setup /f /t REG_DWORD /v %%a /d 0 >nul 2>&1
for %%b in (SkipMachineOOBE SkipUserOOBE) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /f /t REG_DWORD /v %%b /d 1 >nul 2>&1
set "MSG=Success added registry to skipping OOBE."
for %%a in (%_ARGS%) do ^
if /i "%%a"=="/norestart" set norestart=1
if defined norestart (
echo %MSG%
) else (
echo %MSG%. This script will be reboot automatically.
timeout.exe /nobreak /t 3 >nul 2>&1
shutdown.exe /r /t 0 >nul 2>&1
)
goto :end_of_exit


:rollinsider
if /i "%SystemRoot:~0,2%"=="X:" (goto :require_wininstall)
for /f "tokens=4-6 delims=[.NT] " %%v in ('ver') do ^
set "BUILD=%%x" && ^
if /i not "%%v.%%w"=="10.0" (goto :nowin10) else ^
if /i "%%v.%%w"=="10.0" if /i %%x LSS 17763 (goto :nowin10)
set FlightSigningEnabled=0
bcdedit.exe /enum {current}|findstr /i /r /c:"^flightsigning *Yes$" >nul 2>&1
if %ERRORLEVEL% EQU 0 set FlightSigningEnabled=1

for %%a in (%_ARGS%) do (
for %%b in (dev beta rp) do ^
if /i "%%a"=="%%b" (goto :enroll_%%b)
if /i "%%a"=="stop" (goto :stop_insider)
)
goto :no_optroll

:enroll
call :reset_insider_config 1>nul 2>nul
call :add_insider_config 1>nul 2>nul
bcdedit.exe /set {current} flightsigning yes >nul 2>&1
if %FlightSigningEnabled% NEQ 1 set flightreboot=1
goto :success_enroll

:stop_insider
call :reset_insider_config 1>nul 2>nul
bcdedit.exe /deletevalue {current} flightsigning >nul 2>&1
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
if defined flightreboot (
for %%a in (%_ARGS%) do ^
if /i "%%a"=="/norestart" set norestart=1
if defined norestart (
echo %MSG%
) else (
echo %MSG% This script will be reboot automatically.
timeout.exe /nobreak /t 3 >nul 2>&1
shutdown.exe /r /t 0 >nul 2>&1
))
goto :end_of_exit


:reset_insider_config
for %%a in (Account Applicability Cache ClientState UI Restricted ToastNotification) do ^
reg.exe delete HKLM\SOFTWARE\Microsoft\WindowsSelfHost\%%a /f >nul 2>&1
for %%a in (WUMUDCat Ring%Ring% RingExternal RingPreview RingInsiderSlow RingInsiderFast) do ^
reg.exe delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\%%a /f >nul 2>&1
reg.exe delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection /f /v AllowTelemetry >nul 2>&1
reg.exe delete HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection /f /v AllowTelemetry >nul 2>&1
reg.exe delete HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v BranchReadinessLevel >nul 2>&1
reg.exe delete HKLM\SYSTEM\Setup\WindowsUpdate /f /v AllowWindowsUpdate >nul 2>&1
for %%a in ("Setup" "Setup\MoSetup") do ^
reg.exe delete HKLM\SYSTEM\%%~a /f /v AllowUpgradesWithUnsupportedTPMOrCPU >nul 2>&1
for %%a in (BypassTPMCheck BypassStorageCheck BypassSecureBootCheck BypassRAMCheck BypassCPUCheck) do ^
reg.exe delete HKLM\SYSTEM\Setup\LabConfig /f /v %%a >nul 2>&1
reg.exe delete HKCU\SOFTWARE\Microsoft\PCHC /f /v UpgradeEligibility >nul 2>&1
goto :eof

:add_insider_config
if defined BRL ^
reg.exe add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /t REG_DWORD /v BranchReadinessLevel /d %BRL% >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator /f /t REG_DWORD /v EnableUUPScan /d 1 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\Ring%Ring% /f /t REG_DWORD /v Enabled /d 1 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat /f /t REG_DWORD /v WUMUDCATEnabled /d 1 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v EnablePreviewBuilds /d 2 >nul 2>&1
for %%a in (IsBuildFlightingEnabled IsConfigSettingsFlightingEnabled) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v %%a /d 1 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v IsConfigExpFlightingEnabled /d 0 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v TestFlags /d 32 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v RingId /d %RID% >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v Ring /d "%Ring%" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v ContentType /d "%Content%" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v BranchName /d "%Channel%" >nul 2>&1
for %%a in (UIHiddenElements UIDisabledElements UIDisabledElements_Rejuv) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /f /t REG_DWORD /v %%a /d 65535 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /f /t REG_DWORD /v UIHiddenElements_Rejuv /d 65534 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /f /t REG_DWORD /v UIServiceDrivenElementVisibility /d 0 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility /f /t REG_DWORD /v UIErrorMessageVisibility /d 192 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection /f /t REG_DWORD /v AllowTelemetry /d 3 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_SZ /v UIRing /d "%Ring%" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_SZ /v UIContentType /d "%Content%" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_SZ /v UIBranch /d "%Channel%" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v UIOptin /d 1 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v RingBackup /d "%Ring%" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v RingBackupV2 /d "%Ring%" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_SZ /v BranchBackup /d "%Channel%" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Cache /f /t REG_SZ /v PropertyIgnoreList /d "AccountsBlob;;CTACBlob;FlightIDBlob;ServiceDrivenActionResults" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Cache /f /t REG_SZ /v RequestedCTACAppIds /d "WU;FSS" >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Account /f /t REG_DWORD /v SupportedTypes /d 3 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Account /f /t REG_DWORD /v Status /d 8 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\Applicability /f /t REG_DWORD /v UseSettingsExperience /d 0 >nul 2>&1
for %%a in (AllowFSSCommunications MsaUserTicketHr MsaDeviceTicketHr ValidateOnlineHr LastHR ErrorState) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState /f /t REG_DWORD /v %%a /d 0 >nul 2>&1
for %%a in (UICapabilities IgnoreConsolidation FileAllowlistVersion) do ^
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState /f /t REG_DWORD /v %%a /d 1 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState /f /t REG_DWORD /v PilotInfoRing /d 3 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\ClientState /f /t REG_DWORD /v RegistryAllowlistVersion /d 4 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI /f /t REG_DWORD /v UIControllableState /d 0 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v UIDialogConsent /d 0 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v UIUsage /d 26 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v OptOutState /d 25 >nul 2>&1
reg.exe add HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection /f /t REG_DWORD /v AdvancedToggleState /d 24 >nul 2>&1
reg.exe add HKLM\SYSTEM\Setup\WindowsUpdate /f /t REG_DWORD /v AllowWindowsUpdate /d 1 >nul 2>&1
for %%a in ("Setup" "Setup\MoSetup") do ^
reg.exe add HKLM\SYSTEM\%%~a /f /t REG_DWORD /v AllowUpgradesWithUnsupportedTPMOrCPU /d 1 >nul 2>&1
for %%a in (BypassTPMCheck BypassStorageCheck BypassSecureBootCheck BypassRAMCheck BypassCPUCheck) do ^
reg.exe add HKLM\SYSTEM\Setup\LabConfig /f /t REG_DWORD /v %%a /d 1 >nul 2>&1
reg.exe add HKCU\SOFTWARE\Microsoft\PCHC /f /t REG_DWORD /v UpgradeEligibility /d 1 >nul 2>&1

>"%temp%\rollingmessage.reg" (
echo Windows Registry Editor Version 5.00
echo.
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings]
if /i %BUILD% LSS 21990 (
echo "StickyXaml"="<StackPanel xmlns=\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\"><TextBlock Style=\"{StaticResource BodyTextBlockStyle }\">This device has been enrolled to the Windows Insider program using winsetup.bat. If you want to change settings of the enrollment or stop receiving Insider Preview builds, open Terminal and join prompt to directory of winsetup.bat placed, then type <Span FontWeight=\"Bold\">winsetup /rollinsider [ dev | beta | rp | stop ]</Span>.</TextBlock><TextBlock Text=\"Applied configuration\" Margin=\"0,20,0,10\" Style=\"{StaticResource SubtitleTextBlockStyle}\" /><TextBlock Style=\"{StaticResource BodyTextBlockStyle }\" Margin=\"0,0,0,5\"><Run FontFamily=\"Segoe MDL2 Assets\">&#xECA7;</Run> <Span FontWeight=\"SemiBold\">%Fancy%</Span></TextBlock><TextBlock Text=\"Channel: %Channel%\" Style=\"{StaticResource BodyTextBlockStyle }\" /><TextBlock Text=\"Content: %Content%\" Style=\"{StaticResource BodyTextBlockStyle }\" /><TextBlock Text=\"Telemetry settings notice\" Margin=\"0,20,0,10\" Style=\"{StaticResource SubtitleTextBlockStyle}\" /><TextBlock Style=\"{StaticResource BodyTextBlockStyle }\">Windows Insider Program requires your diagnostic data collection settings to be set to <Span FontWeight=\"SemiBold\">Full</Span>. You can verify or modify your current settings in <Span FontWeight=\"SemiBold\">Diagnostics &amp; feedback</Span>.</TextBlock><Button Command=\"{StaticResource ActivateUriCommand}\" CommandParameter=\"ms-settings:privacy-feedback\" Margin=\"0,10,0,0\"><TextBlock Margin=\"5,0,5,0\">Open Diagnostics &amp; feedback</TextBlock></Button></StackPanel>"
) else (
echo "StickyMessage"="{\"Message\":\"Device enrolled using winsetup.bat\",\"LinkTitle\":\"\",\"LinkUrl\":\"\",\"DynamicXaml\":\"^<StackPanel xmlns=\\\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\\\"^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle }\\\"^>This device has been enrolled to the Windows Insider program using winsetup.bat. If you want to change settings of the enrollment or stop receiving Insider Preview builds, open Terminal and join prompt to directory of winsetup.bat placed, then type ^<Span FontWeight=\\\"Bold\\\"^>winsetup /rollinsider [ dev ^| beta ^| rp ^| stop ]^</Span^>.^</TextBlock^>^<TextBlock Text=\\\"Applied configuration\\\" Margin=\\\"0,20,0,10\\\" Style=\\\"{StaticResource SubtitleTextBlockStyle}\\\" /^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle }\\\" Margin=\\\"0,0,0,5\\\"^>^<Run FontFamily=\\\"Segoe MDL2 Assets\\\"^>^&#xECA7;^</Run^> ^<Span FontWeight=\\\"SemiBold\\\"^>%Fancy%^</Span^>^</TextBlock^>^<TextBlock Text=\\\"Channel: %Channel%\\\" Style=\\\"{StaticResource BodyTextBlockStyle }\\\" /^>^<TextBlock Text=\\\"Content: %Content%\\\" Style=\\\"{StaticResource BodyTextBlockStyle }\\\" /^>^<TextBlock Text=\\\"Telemetry settings notice\\\" Margin=\\\"0,20,0,10\\\" Style=\\\"{StaticResource SubtitleTextBlockStyle}\\\" /^>^<TextBlock Style=\\\"{StaticResource BodyTextBlockStyle }\\\"^>Windows Insider Program requires your diagnostic data collection settings to be set to ^<Span FontWeight=\\\"SemiBold\\\"^>Full^</Span^>. You can verify or modify your current settings in ^<Span FontWeight=\\\"SemiBold\\\"^>Diagnostics ^&amp; feedback^</Span^>.^</TextBlock^>^<Button Command=\\\"{StaticResource ActivateUriCommand}\\\" CommandParameter=\\\"ms-settings:privacy-feedback\\\" Margin=\\\"0,10,0,0\\\"^>^<TextBlock Margin=\\\"5,0,5,0\\\"^>Open Diagnostics ^&amp; feedback^</TextBlock^>^</Button^>^</StackPanel^>\",\"Severity\":0}"
))
regedit.exe /s "%temp%\rollingmessage.reg" >nul 2>&1
del /f /q "%temp%\rollingmessage.reg" >nul 2>&1
goto :eof



:help
echo WINSETUP USAGE:
echo.
echo WINSETUP [ [/install] 'Target' [ 'Boot' [/MBR ^| /EFI ^| /all] ] /scandisk ]
echo.
echo WINSETUP [ [/upgrade] /bypasstpm ]
echo.
echo WINSETUP [/fdisk]
echo.
echo WINSETUP [/adduser] [/addadmin]
echo.
echo WINSETUP [/skipoobe] [ [/skipoobenew ^| /bypassnro ^| /rollinsider] /norestart ]
echo.
echo    /install        Install Windows
echo       /MBR         Read Master Boot Record during installing Windows
echo       /EFI         Read UEFI Boot during installing Windows
echo       /all         Read all boot ^(MBR and EFI^) during installing Windows
echo       /scandisk    Scans the target drive during install Windows
echo    /upgrade        Upgrade Windows
echo       /bypasstpm   Do upgrade Windows with skip requires TPM check
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

:errmsg
if not "%MSG1%"=="" echo.%MSG1%
if not "%MSG2%"=="" echo.%MSG2%
if not "%MSG3%"=="" echo.%MSG3%
goto end_of_exit

:require_admin
set "MSG1=Access is denied."
goto :errmsg

:require_winpe
set "MSG1=This script only allowed in Setup Environment."
goto :errmsg

:require_wininstall
set "MSG1=This script only allowed in system installed on your disk."
goto :errmsg

:require_wim
set "MSG1=No installable media found. Please insert Windows installation and try again."
goto :errmsg

:require_imaging
set "MSG1=Imaging service application unavailable."
goto :errmsg

:media_readonly
set "MSG1=The installable directory is write-protected or read only."
goto :errmsg

:no_upgrade
set "MSG1=No installable directory found. Please insert Windows installation or run Windows Update to get new Windows version to updating and try again."
goto :errmsg

:no_targetpath
set "MSG1=Invalid target path to install Windows."
goto :errmsg

:no_targetexist
set "MSG1=Target drive is not found or not formatted."
goto :errmsg

:no_allowfloppy
set "MSG1=You do not allow install to floppy drive letter."
goto :errmsg

:no_args
set "MSG1=Invalid arguments."
goto :errmsg

:installerror
set "MSG1=Error install Windows. Please try again."
goto :errmsg

:invalid_edition
set "MSG1=Invalid edition selected."
call :errmsg
goto :loopinstall

:no_optroll
set "MSG1=Invalid options."
set "MSG2= "
set "MSG3=Available options to enroll Windows:  dev ^| beta ^| rp ^| stop"
goto :errmsg

:nowin10
:nowin11
echo This switch parameter requires a newer version of Windows.
goto end_of_exit

:ntold
echo This script requires a newer version of Windows NT.
goto end_of_exit

:windos_2
echo This script requires Microsoft Windows NT.
goto end_of_exit

:msdos
echo This script cannot be run in DOS mode.
goto end_of_exit

:end_of_exit
@ if %OS%!==Windows_NT! endlocal
@ if %OLD_WINNT%!==0!  goto :eof
@ echo on
