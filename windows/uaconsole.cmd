@ GOTO STARTSCRIPT

@ ::
@ :: Microsoft Windows(R) Command Script
@ :: Copyright (c) 1990-2020 Microsoft Corp. All rights reserved.
@ ::

@ ::
@ :: DETAILS
@ ::

@ ::
@ :: UAConsole.cmd
@ :: Running as other user on Command Processor
@ :: Running as administrator on Command Processor
@ ::
@ :: Date/Time Created:          03/06/2020  6:22am
@ :: Operating System Created:   Windows 7 Ultimate
@ ::
@ :: This script created by:
@ ::   Faizal Hamzah
@ ::   The Firefox Foundation
@ ::
@ ::
@ :: VersionInfo:
@ ::
@ ::    File version:      6,1,7601,23537
@ ::    Product Version:   6,1,7601,23537
@ ::
@ ::    CompanyName:       Microsoft Corporation
@ ::    FileDescription:   Run as other user Console Script Tool
@ ::                       Run as administrator Console Script Tool
@ ::    FileVersion:       6.1.7601.23537 (win7sp1_ldr.160829-0600)
@ ::    InternalName:      uaconsole
@ ::    LegalCopyright:    (c) Microsoft Corporation. All rights reserved.
@ ::    OriginalFileName:  UAConsole.cmd
@ ::    ProductName:       Microsoft(R) Windows(R) Operating System
@ ::    ProductVersion:    6.1.7601.23537
@ ::


@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxb
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxd
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxe
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxf
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxg
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxh
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxi
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxj
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxk
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxl
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxm
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxn
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxo
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxp
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxq
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxr
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxs
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxt
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxu
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxv
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxw
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxy
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxz
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxb
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxd
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxe
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxf
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxg
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxh
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxi
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxj
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxk
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxl
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxm
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxn
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxo
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxp
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxq
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxr
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxs
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxt
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxu
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxv
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxw
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxy
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxz
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxb
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxd
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxe
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxf
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxg
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxh
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxi
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxj
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxk
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxl
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxm
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxn
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxo
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxp
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxq
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxr
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxs
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxt
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxu
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxv
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxw
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxy
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxz
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1



:: BEGIN

:STARTSCRIPT
@ echo off

rem Windows/DOS/OS2 it does not working on this script.
if "%OS%" == "Windows_NT"  goto next
ver | find "Operating System/2"  > nul
if not errorlevel 1 goto winos2exit
if exist %windir%\..\msdos.sys  find "WinDir" %windir%\..\msdos.sys  > nul
if not errorlevel 1  goto winos2exit
goto dosexit


:next
@ setlocal
@ break off

rem Windows NT it does not working on this script.
for %%v in ( Daytona Cairo Hydra Neptune NT ) do ^
ver | findstr /r /c:"%%v"  > nul  && ^
if not errorlevel 1  set OLD_WINNT=1
if "%OLD_WINNT%" == "1"  goto ntoldexit
if not defined OLD_WINNT  setlocal EnableExtensions EnableDelayedExpansion

set "_UPPERCASE=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "_LOWERCASE=abcdefghijklmnopqrstuvwxyz"
set "_LSTRING=%~n0"
set "_USTRING=%~n0"

set "basedir=%~dp0"
set "basedir=%basedir:~0,-1%"

set "params=%*"
set "params=!params:"=""!"
set "command=%1"
set "command=!command:"=""!"

set "params=%params:!==^^!%"
set "params=!params:%command%=!"
set "params=!params:%%=%%%%!"
set "params_1=%params%"

set "commands=!command:"=""!"

for /l %%a in ( 0, 1, 25 ) do (
  call set "_A=%%_UPPERCASE:~%%a,1%%"
  call set "_B=%%_LOWERCASE:~%%a,1%%"

  call set "_LSTRING=%%_LSTRING:!_A!=!_B!%%"

  call set "_USTRING=%%_USTRING:!_B!=!_A!%%"
  call set "command=%%command:!_B!=!_A!%%"
  call set "params_1=%%params_1:!_B!=!_A!%%"
)

if "%params%" == "%%=%%%%"  (
  set params=
  set params_1=
)

rem Set program version for any Windows version
for /f "tokens=4-7 delims=[.NT] " %%a in ('ver') do (
  rem Windows 10 and Windows Server 2016/2019
  if "%%a.%%b" == "10.0"            set "VERSION=%%a.%%b.%%c.%%d"
  if "%%a.%%b.%%c" == "10.0.15063"  set "VERSION=10.0.10240.16384"
  if "%%a.%%b.%%c" == "10.0.14393"  set "VERSION=10.0.10240.16384"
  if "%%a.%%b.%%c" == "10.0.10586"  set "VERSION=10.0.10240.16384"
  if "%%a.%%b.%%c" == "10.0.10240"  set "VERSION=10.0.10240.16384"
  if "%%a" == "6"                   set "VERSION=6.3.9600.17415"

  rem Windows 8 and Windows Server 2012/2012 R2
  if "%%a.%%b" == "6.3"             set "VERSION=6.3.9600.17415"
  if "%%a.%%b" == "6.2"             set "VERSION=6.2.9200.16384"

  rem Windows 7 and Windows Server 2008 R2
  if "%%a.%%b" == "6.1"             set "VERSION=6.0.6000.16386"
  if "%%a.%%b.%%c" == "6.1.8400"    set "VERSION=6.1.7601.23537"
  if "%%a.%%b.%%c" == "6.1.7601"    set "VERSION=6.1.7601.23537"
  if "%%a.%%b.%%c" == "6.1.7600"    set "VERSION=6.1.7600.16385"

  rem Windows Vista and Windows Server 2008
  if "%%a.%%b" == "6.0"             set "VERSION=5.2.3790.1830"   &&  set 2kxp=1
  if "%%a.%%b.%%c" == "6.0.6003"    set "VERSION=6.0.6003.18006"  &&  set 2kxp=
  if "%%a.%%b.%%c" == "6.0.6002"    set "VERSION=6.0.6002.18005"  &&  set 2kxp=
  if "%%a.%%b.%%c" == "6.0.6001"    set "VERSION=6.0.6001.18000"  &&  set 2kxp=
  if "%%a.%%b.%%c" == "6.0.6000"    set "VERSION=6.0.6000.16386"  &&  set 2kxp=

  rem Windows XP x86/x64 and Windows Server 2003
  if "%%a.%%b" == "5.2"             set "VERSION=5.2.3790.1830"   &&  set 2kxp=1
  if "%%b.%%c" == "5.1"             set "VERSION=5.1.2600.2180"   &&  set 2kxp=1

  rem Windows 2000/NT 5.0
  if "%%b.%%c" == "5.00"            set "VERSION=5.00.2195.6717"  &&  set 2kxp=1
)

if [%1] == []  ( goto :nosyntx )
for %%p in (
  A B C D E F G I J K L M N
  O P Q R S T U V W X Y Z
  1 2 3 4 5 6 7 8 9 0 . / \
  [ ] { } - _ + $ # @ ` ~ :
) do ^
if "%command%" == "/%%p"   ( set invalid=1 ) else ^
if "%command%" == "-%%p"   ( set invalid=1 ) else ^
if "%command%" == "--%%p"  ( set invalid=1 )
for %%p in ( /h /H -h --h --H ) do ^
if "%1" == "%%p"           ( set invalid=1 )
if defined invalid  goto :nosyntx

for %%s in ( - / ) do ^
if [%1] == [%%s?]          ( goto :nosyntx ) else ^
for %%p in ( -HELP --HELP ) do ^
if "%command%" == "%%p"    ( goto :nosyntx ) else ^
if "%1" == "-H"            ( goto :nosyntx )


:: Starting execute...
for %%c in (
  APPEND ARP AT ATTRIB AUTOFAIL ASSOC BCDEDIT BCDBOOT BITSADMIN BOOTREC BOOTSECT BREAK
  CACLS CALL CD CERTREQ CERTUTIL CHANGE CHCP CHDIR CHKDSK CHKNTFS CHOICE CIPHER CLIP
  CLS CMDKEY COLOR COMP COMPACT CONVERT COPY CSVDE DATE DEFRAG DEL DELTREE DEVCON DIR
  DIRQUOTA DISKCOMP DISKCOPY DISKSHADOW DISM DNSCMD DOSKEY DRIVERQUERY DSACLS DSADD
  DSGET DSQUERY DSMOD DSMOVE DSRM DSMGMT DPATH ECHO ENDLOCAL ERASE EXE2BIN EXIT EXPAND
  EXTRACT EVENTCREATE FASTHELP FASTOPEN FC FIND FINDSTR FOR FORFILES FORMAT FREEDISK
  FSUTIL FTP FTYPE GETMAC GOTO GPRESULT GPUPDATE GRAFTABL GRAPHICS HELP HOSTNAME ICACLS
  IF IMAGEX INUSE IPCONFIG KB16 KEYB LABEL LOADFIX LODCTR LOGMAN LOGOFF MAKECAB MD MEM
  MKDIR MKLINK MODE MORE MOUNTVOL MOVE MSG NBTSTAT NET NETCFG NETDOM NETSH NETSTAT NLSFUNC
  NLTEST NSLOOKUP NTDSUTIL OPENFILES PATH PATHPING PAUSE PING POPD POWERCFG PRINT PRNCFG
  PRNMGR PROMPT PUSHD QUERY QUSER RD RECOVER REG REGINI REGSVR REGSVR32 REM REN RENAME
  REPLACE RESET RESTORE RMDIR ROBOCOPY ROUTE RUNAS RUNDLL RUNDLL32 SC SET SETLOCAL SETSPN
  SETVER SETX SFC SHARE SHIFT SHUTDOWN SORT SSH START SUBINACL SUBST SYSTEMINFO TAKEOWN
  TASKKILL TASKLIST TELNET TIME TIMEOUT TITLE TRACERT TREE TSDISCON TSKILL TYPE TYPEPERF
  TZUTIL VER VERIFY VOL VSSADMIN W32TM WAITFOR WBADMIN WECUTIL WEVTUTIL WHERE WHOAMI
  WINRM WINRS WMIC XCACLS XCOPY
) do (
if "%command%" == "%%c"  (
  set "commands=CMD.EXE"
  set "params=/C %%c %params% && echo. && pause"
) else ^
for %%x in ( EXE COM ) do ^
if "%command%" == "%%c.%%x"  (
  set "commands=CMD.EXE"
  set "params=/C %%c %params% && echo. && pause"
) )

for %%c in ( AUX COM1 COM2 COM3 COM4 CON LPT1 LPT2 LPT3 LPT4 NUL PRN ) do ^
if "%command%" == "%%c"  set port=1

for %%c in ( CMD CMD.EXE ) do ^
if "%command%" == "%%c"  (
if defined params  (
  set "commands=%%c"
  set "params=/C %%c %params% && echo. && pause"
)
if "%params_1%" == " /?"  set "params=%params% && echo. && pause"
)

for %%c in ( COMMAND COMMAND.COM ) do ^
if "%command%" == "%%c"  (
if not defined params  (
  set "commands=CMD.EXE"
  set "params=/C %%c"
) else (
  set "commands=CMD.EXE"
  set "params=/C %%c %params% && echo. && pause"
)
if "%params_1%" == " /?"  (
  set "commands=CMD.EXE"
  set "params=/C %%c %params% && echo. && pause"
) )

for %%c in ( PWSH PWSH.EXE POWERSHELL POWERSHELL.EXE ) do ^
if "%command%" == "%%c"  (
if defined params  (
  set "commands=CMD.EXE"
  set "params=/C %%c %params% && echo. && pause"
)
if "%params_1%" == " -HELP"  (
  set "commands=CMD.EXE"
  set "params=/C %%c %params% && echo. && pause"
) else ^
for %%d in ( - / ) do ^
if "%params_1%" == " %%d?"   (
  set "commands=CMD.EXE"
  set "params=/C %%c %params% && echo. && pause"
) )

for %%c in ( WSL WSL.EXE ) do ^
for %%d in ( --help -h ) do ^
if "%command%" == "%%c"  (
if defined params  (
  set "commands=CMD.EXE"
  set "params=/C %%c %params% && echo. && pause"
)
if "%params_1%" == " %%d"  (
  set "commands=CMD.EXE"
  set "params=/C %params% && echo. && pause"
) )

call cacls.exe %SystemRoot%\system32\config\system  > nul 2>&1
if %errorlevel% NEQ 0  (

  :: Title text screen
  call :runas_title
  if defined port  goto :comexterr
  if exist %SystemRoot%\system32\timeout.exe  call timeout.exe /t 1 /nobreak  > nul
  call :runas_do
  > "%temp%\%~n0.vbs" (
    echo ' Copyright ^(c^) Microsoft Corporation.  All rights reserved.
    echo ' VBScript Source File
    echo ' Script Name: getadmin.vbs
    echo.
    echo dim args : args = "%params% "
    echo dim run : set run = createobject^("shell.application"^)
    echo for each strArg in wscript.arguments
    echo args = args ^& strArg ^& " "
    echo next
    echo.
    echo run.shellexecute _
    echo "%commands%", args, _
    echo "%basedir%", "runas", 1
  )
  call cscript.exe //nologo //e:vbscript "%temp%\%~n0.vbs"  > nul 2>&1
  del /q "%temp%\%~n0.vbs"  > nul 2>&1

) else (

  set admin_mode=1
  if defined port  goto :comexterr
  call :runas_do
  %*

)
@ call :end_of_exit
@ goto :eof


:: Dialog text screen
:runas_title
echo.
if defined 2kxp  ( echo Run as other user Console Script Tool ) ^
else  ( echo Run as administrator Console Script Tool )
echo Version: %VERSION%
goto :eof

:runas_do
if not defined admin_mode  (
  echo.
  if defined 2kxp  ( echo Running as other user... ) ^
  else  ( echo Requesting administrative privileges... )
) else ^
if defined admin_mode  (
  for %%c in ( CMD CMD.EXE COMMAND COMMAND.COM ) do (
    if "%command%" == "%%c"  (
    if "%params_1%" == "/?"  goto :eof
  ) )
  for %%c in ( PWSH PWSH.EXE POWERSHELL POWERSHELL.EXE ) do (
  for %%d in ( - / ) do (
    if "%command%" == "%%c"  (
    if "%params_1%" == "-HELP"  goto :eof
    if "%params_1%" == "%%d?"   goto :eof
  ) ) )
  for %%c in ( WSL WSL.EXE ) do (
  for %%d in ( --help -h ) do (
    if "%command%" == "%%c"  (
    if "%params_1%" == "%%d"  goto :eof
  ) ) )
  echo You are in the administrator.
)
goto :eof

:comexterr
if not defined admin_mode echo.
echo Invalid commands and parameters.
@ call :end_of_exit
@ goto :eof

:nosyntx
call :runas_title
if defined invalid  (
  echo.
  echo Invalid parameters.
  echo See '-?', '/?' or '-H', '-help', '--help' to view manual command.
  @ call :end_of_exit
  @ goto :eof
)
echo.
echo.
echo USAGE^:
echo.
echo %_USTRING%  ^[program ^| command^] ^[parameters ^| arguments or syntax^]
echo.
echo Examples^:
echo ^> %_LSTRING% dir
echo ^> %_LSTRING% cd ^/d C^:^\path^\to^\dir
echo ^> %_LSTRING% copy sourcefile.txt destfile.txt
echo ^> %_LSTRING% cmd.exe
echo ^> %_LSTRING% cmd.exe ^/c dir
echo ^> %_LSTRING% "C:\path\to\dir\program.exe"
echo ^> %_LSTRING% notepad.exe C^:^\path^\to^\dir^\filename.txt
echo ^> %_LSTRING% notepad.exe "C:\path\to\dir\filename.txt"
echo.
echo NOTE^:  You can using drive^:^\path^\to^\dir^\filename and parameters^/
echo        ^arguments or syntax commands on program while it running.
echo NOTE^:  If you type parameter double 'and' symbols ^("&&"^), you add logical
echo        ^'and' symbols ^("^"^) in between double 'and' symbols.
echo        ^Command parameters: ^("^&^&"^)
echo NOTE^:  File ^(not program^) or batch script cannot work run on current user.
@ call :end_of_exit
@ goto :eof

:dosexit
echo This program cannot be run in DOS mode.
@ GOTO ENDSCRIPT

:winos2exit
echo This script requires Microsoft Windows NT.
@ GOTO ENDSCRIPT

:ntoldexit
echo This script requires a newer version of Windows NT.

:end_of_exit
@ endlocal
@ GOTO ENDSCRIPT

:: END



@ ::
@ :: COMMENTS
@ ::

@ ::
@ :: On above and below [@ :: xxxxxx...] are only dummy code/text that have
@ :: no function in this script.
@ ::

@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxb
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxd
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxe
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxf
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxg
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxh
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxi
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxj
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxk
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxl
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxm
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxn
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxo
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxp
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxq
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxr
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxs
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxt
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxu
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxv
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxw
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxy
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxz
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxb
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxd
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxe
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxf
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxg
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxh
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxi
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxj
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxk
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxl
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxm
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxn
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxo
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxp
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxq
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxr
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxs
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxt
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxu
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxv
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxw
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxy
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxz
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxb
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxc
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxd
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxe
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxf
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxg
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxh
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxi
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxj
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxk
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxl
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxm
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxn
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxo
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxp
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxq
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxr
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxs
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxt
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxu
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxv
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxw
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxy
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxz
@ :: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0

:ENDSCRIPT
@ echo on
