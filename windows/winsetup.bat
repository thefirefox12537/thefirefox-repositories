@echo off
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
setlocal
for %%v in (Daytona Cairo Hydra Neptune NT) do ^
ver|find "%%v" > nul & ^
if not errorlevel 1 (set OLD_WINNT=1)
if %OLD_WINNT%!==1! (goto ntold) ^
else (setlocal EnableExtensions EnableDelayedExpansion)
for /f "tokens=4-6 delims=[.NT] " %%v in ('ver') do (
for %%a in (00 01) do if "%%w.%%x"=="5.%%a" (goto :ntold)
for %%b in (1 2 3) do if "%%v.%%w"=="5.%%b" (goto :ntold)
)

set "drive=CDEFGHIJKLMNOPQRSTUVWXYZ"
set "alpha=ABCDEFGHIJKLMNOPQRSTUVWYZabcdefghijklmnopqrstuvwyz"

set "_UCASE=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "_LCASE=abcdefghijklmnopqrstuvwxyz"
set "_PARAM=%1"
set "_DRV1=%2"
set "_DRV2=%3"
set "_TYPE=%4"

for /l %%a in (0,1,25) do (
call set "_FROM=%%_LCASE:~%%a,1%%"
call set "_TO=%%_UCASE:~%%a,1%%"
call set "_PARAM=%%_PARAM:!_FROM!=!_TO!%%"
call set "_DRV1=%%_DRV1:!_FROM!=!_TO!%%"
call set "_DRV2=%%_DRV2:!_FROM!=!_TO!%%"
call set "_TYPE=%%_TYPE:!_FROM!=!_TO!%%"
)

if "%1"=="" goto :help
if "%1"=="/?" goto :help

set "REGDIR=%SystemRoot%\system32\config"
if "%SystemRoot:~0,2%"=="X:" (bcdedit /store %REGDIR%\bcd-template > nul 2>&1) ^
else (icacls %REGDIR%\system > nul 2>&1)
if %ERRORLEVEL% NEQ 0 (
echo Access denied.
endlocal
goto :eof
)

if "%_PARAM%"=="/install" goto :install
if "%_PARAM%"=="/adduser" goto :adduser
if "%_PARAM%"=="/addadmin" goto :addadmin
if "%_PARAM%"=="/skipoobe" goto :skipoobe

:install
if not "%SystemRoot:~0,2%"=="X:" (
echo This script only allowed in Setup Environment.
endlocal
goto :eof
)
for %%a in (BypassTPMCheck BypassSecureBootCheck BypassRAMCheck BypassCPUCheck) do ^
reg add HKLM\Setup\LabConfig /V %%a /D 1 /T REG_DWORD > nul 2>&1
reg add HKLM\System\Setup /V AllowUpgradesWithUnsupportedTPMOrCPU /D 1 /T REG_DWORD > nul 2>&1
::IMAGEX
for /l %%d in (0,1,23) do ^
if exist "!drive:~%%d,1!:\sources\imagex.exe" (set "imagexcd=!drive:~%%d,1!:\sources\imagex.exe")
for %%f in ("%~dp0\imagex.exe" %imagexcd% %SystemRoot%\system32\imagex.exe) do ^
if exist %%f (
set "imagex=%%f"
)
if defined imagex (set "imaging=imagex" & goto :next)
::DISM
if exist %SystemRoot%\system32\dism.exe (
for /f "usebackq tokens=2-3 delims=:. " %%v in (`%SystemRoot%\system32\dism^|find "Version:"`) do ^
if %%v EQU 6 if %%w LSS 2 (goto :ntold) else ^
if %%v LSS 6 (goto :ntold)
set "dism=%SystemRoot%\system32\dism.exe"
)
if defined dism (set "imaging=dism" & goto :next)

:next
if %2!==! (echo Invalid target path to install Windows.& endlocal& goto :eof)
if %3!==! (echo Invalid arguments.& endlocal& goto :eof)

if not exist %2\nul (
echo Target drive is not found or not formatted.
endlocal
goto :eof
)

set "installsrc=sources\install"
for /l %%d in (0,1,23) do (
if exist "!drive:~%%d,1!:\%installsrc%.wim" (
set "installsrc=!drive:~%%d,1!:\%installsrc%.wim"
set "opt=imagefile"
)
if exist "!drive:~%%d,1!:\%installsrc%.swm" (
set "imagexswm=/ref ^"!drive:~%%d,1!:\%installsrc%*.swm^""
set "dismswm=/swmfile:^"!drive:~%%d,1!:\%installsrc%*.swm^""
set "installsrc=!drive:~%%d,1!:\%installsrc%.swm"
set "opt=imagefile"
)
if exist "!drive:~%%d,1!:\%installsrc%.esd" (
set "installsrc=!drive:~%%d,1!:\%installsrc%.esd"
set "opt=imagefile"
)
)

if not defined opt (
echo No installable media found. Please insert Windows installation and try again.
endlocal
goto :eof
)
if defined imaging (echo Type the available index number to install Windows.& goto :loopinstall)
echo Imaging service application unavailable.
endlocal
goto :eof

:loopinstall
echo.
echo Install source: %installsrc%
echo Available edition:
if "%imaging%"=="dism" ^
for /f "tokens=2* delims=:" %%a in ('call %dism% /get-imageinfo /%opt%:"%installsrc%"^|find "Name"') do ^
if "%%a"==" " (echo.  NOT IDENTIFIED NAME >> "%tmp%\%~n0.txt") ^
else (echo  %%a >> "%tmp%\%~n0.txt")
if "%imaging%"=="imagex" ^
for /f "tokens=3* delims=><" %%a in ('call %imagex% /info "%installsrc%"^|find "<NAME>"') do ^
if "%%a"==" " (echo.  NOT IDENTIFIED NAME >> "%tmp%\%~n0.txt") ^
else (echo  %%a >> "%tmp%\%~n0.txt")
type "%tmp%\%~n0.txt"|find /n " " && del /q "%tmp%\%~n0.txt" > nul 2>&1
echo.
set /p "INDEX=INDEX> "
for %%x in (X x) do if %INDEX%!==%%x! (echo Exitting...& endlocal& goto :eof)
if not defined INDEX (echo Invalid edition selected.& goto :loopinstall)
for /l %%s in (0,1,49) do ^
if "%INDEX%"=="!alpha:~%%s,1!" (echo Invalid edition selected.& goto :loopinstall)
if %INDEX% EQU 0 (echo Invalid edition selected.& goto :loopinstall)

echo Expanding Windows...
if "%imaging%"=="dism" %dism% /apply-image /%opt%:"%installsrc%" %dismswm% /index:%INDEX% /applydir:%2\
if "%imaging%"=="imagex" %imagex% /apply "%installsrc%" %imagexswm% %INDEX% %2\
if %ERRORLEVEL% NEQ 0 goto :installerror
if not exist %2\Windows\nul goto :installerror

:buildbcd
echo Cleaning old Boot Configuration Data store...
for %%i in (
autoexec.* config.* command.*
io.* msdos.* ibmbio.* ibmdos.*
bootsect.bak bootsect.dos
bootmgr BOOTNXT BOOTTGT
boot.ini ntdetect.com ntldr
) do (
del /f /ashr /q %2\%%i > nul 2>&1
del /f /ashr /q %3\%%i > nul 2>&1
)
for %%d in (boot efi recovery) do (
rd /s /q %2\%%d > nul 2>&1
rd /s /q %3\%%d > nul 2>&1
)

echo Rebuilding Boot Configuration Data store...
if "%_TYPE%"=="/EFI" (
%SystemRoot%\system32\bcdboot %2\Windows /s %3 /f UEFI > nul 2>&1
) else ^
if "%_TYPE%"=="/ALL" (
%SystemRoot%\system32\bcdboot %2\Windows /s %3 /f all > nul 2>&1
%SystemRoot%\system32\bootsect /nt60 %3 /mbr /force > nul 2>&1
) else ^
if "%_TYPE%"=="/MBR" (
%SystemRoot%\system32\bcdboot %2\Windows /s %3 /f BIOS > nul 2>&1
%SystemRoot%\system32\bootsect /nt60 %3 /mbr > nul 2>&1
) else ^
if "%_DRV2%"=="/MBR" (
%SystemRoot%\system32\bcdboot %2\Windows /f BIOS > nul 2>&1
%SystemRoot%\system32\bootsect /nt60 %2 /mbr > nul 2>&1
) else ^
if "%_DRV2%"=="/MBRXP" (
copy "%~dp0\nt5boot\NTDETECT.COM" %2\ > nul 2>&1
copy "%~dp0\nt5boot\ntldr" %2\ > nul 2>&1
>  %2\boot.ini echo [boot loader]
>> %2\boot.ini echo timeout=30
>> %2\boot.ini echo default=multi^(0^)disk^(0^)rdisk^(0^)partition^(1^)\WINDOWS
>> %2\boot.ini echo.
>> %2\boot.ini echo [operating systems]
>> %2\boot.ini echo multi^(0^)disk^(0^)rdisk^(0^)partition^(1^)\WINDOWS="Microsoft Windows XP" /noexecute=optin /fastdetect
attrib +s +h +r %2\NTDETECT.COM > nul 2>&1
attrib +s +h +r %2\ntldr > nul 2>&1
attrib +s +h -r %2\boot.ini > nul 2>&1
%SystemRoot%\system32\bootsect /nt52 %2 /mbr > nul 2>&1
)

echo Install Windows successfully completed.
for /f %%c in ('copy /z "%~dpf0" nul') do set CR=%%c
for /l %%s in (10,-1,1) do (
if %%s EQU 1 (set /p "=This script will be restart automatically in 1 second...  !CR!" < nul) ^
else (set /p "=This script will be restart automatically in %%s seconds... !CR!" < nul)
ping -n 2 127.0.0.1 > nul
)
echo.
wpeutil reboot
endlocal
goto :eof

:installerror
echo Error install Windows. Please try again.
endlocal
goto :eof


:adduser
echo Type your name to add the new computer!
set /p "USERADD=USER> "
echo Type the password to add your new user in the new computer!
call :getpasswd PASSWORD "PASSWD> "
if not defined USERADD (echo Type incorrect. Please try again.& goto :adduser)

net user /add %USERADD% %PASSWORD% > nul 2>&1
net localgroup /add Administrators %USERADD% > nul 2>&1
net localgroup /add Users %USERADD% > nul 2>&1

echo Successful added.
endlocal
goto :eof


:addadmin
net user /active Administrator > nul 2>&1

echo Successful added.
choice /c:yn /m "Are you want to add Administrator password? " /n
if %ERRORLEVEL% EQU 2 (endlocal & goto :eof)
echo Type the password to Administrator!
call :getpasswd PASSWORD "PASSWD> "
if not defined PASSWORD (echo Abort add password.& endlocal& goto :eof)

net user Administrator %PASSWORD% > nul 2>&1
echo Successful added password.
endlocal
goto :eof

:getpasswd
set "_password="
for /f %%a in ('"prompt;$H&for %%b in (0) do rem"') do ^
set "BS=%%a"
set /p "=%~2" < nul

:keyloop
set "key="
for /f "delims=" %%a in ('xcopy /l /w "%~f0" "%~f0" 2^> nul') do ^
if not defined key ^
set "key=%%a"
set "key=%key:~-1%"
if defined key (
if "%key%"=="%BS%" (
if defined _password (set "_password=%_password:~0,-1%" & set /p "=!BS! !BS!" < nul)) ^
else (set "_password=%_password%%key%" & set /p "=" < nul)
goto :keyloop
)
echo/
set "%~1=%_password%"
goto :eof

:skipoobe
taskkill /f /im msoobe.exe
start explorer.exe
endlocal
goto :eof

:help
echo USAGE:
echo.
echo WINSETUP [/INSTALL 'Target Path' ['Reserved Drive' /MBR ^| /EFI ^| /ALL]]
echo          [/ADDUSER] [/ADDADMIN] [/SKIPOOBE]
echo.
echo    /INSTALL      Install Windows
echo       /MBR       Read Master Boot Record during installing Windows
echo       /EFI       Read EFI Boot during installing Windows
echo       /ALL       Read all boot (MBR and EFI) during installing Windows
echo    /ADDUSER      Add user if you were on Out-Of the Box Experience
echo    /ADDADMIN     Activate Administrator user if you were on Out-Of the
echo                  Box Experience
echo    /SKIPOOBE     Skip Out-Of the Box Experience and quick start Explorer
echo.
echo NOTE:  Before installing Windows, make sure you prepare the partition
echo        first.
endlocal
goto :eof

:ntold
echo This script requires a newer version of Windows NT.
endlocal
goto end

:windos_2
echo This script requires Microsoft Windows NT.
goto end

:msdos
echo This script cannot be run in DOS mode.
goto end

:end
@echo on
