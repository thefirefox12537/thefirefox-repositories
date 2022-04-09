#!/usr/bin/env pwsh
#requires -version 2

<#PSScriptInfo
  .VERSION 1.1.0.0
  .GUID 76d4b4f3-04bb-456b-8253-d082e81f5390
  .AUTHOR Faizal Hamzah
  .PROJECTURI
  .LICENSEURI
  .ICONURI
  .COMPANYNAME
  .COPYRIGHT
  .TAGS adb.exe fastboot.exe platform-tools
  .REQUIREDSCRIPTS
  .EXTERNALMODULEDEPENDENCIES
  .EXTERNALSCRIPTDEPENDENCIES
  .RELEASENOTES
#>

<#
  .DESCRIPTION
      Android SDK Platform Tools with USB Driver installer for Windows
#>

param([switch][alias('h')]$Help)

function Error-Dialog {
    $Null = $MsgBoxDialog::Show(
    "Installation failed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    )
    Invoke-ExitScript 1
}

function IsAdmin {
    (
        [System.Security.Principal.WindowsPrincipal]`
        [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [System.Security.Principal.WindowsBuiltinRole]::Administrator
    )
}

function Invoke-PauseScript {
    $Null = $(
    Write-Host -NoNewLine "Press any key to continue . . . "
    [System.Console]::ReadKey($True)
    )
}

function Invoke-ExitScript {
    param([int32][AllowNull()]$ErrorLevel)

    $Host.UI.RawUI.WindowTitle = $RestoreTitle
    if($ErrorLevel -eq 1 -and $ErrorMsg) {
        if($PSVersionTable.PSVersion -lt (New-Object System.Version 5,0))
       {$ErrorActionPreference = "Stop"} else {$script:ErrorActionPreference = "Stop"}
        throw $ErrorMsg
    } else {
        exit($ErrorLevel)
    }
}

$RestoreTitle = $Host.UI.RawUI.WindowTitle
$Host.UI.RawUI.WindowTitle = "Android SDK Platform Tools installer"
$Android = "android-sdk"
$Title = "platform-tools"
$AppTitle = "Android SDK Platform Tools with USB drivers"
$AppFileName = "install-$Android-$Title.ps1"
$ProgramGroups = "${env:AppData}\Microsoft\Windows\Start Menu\Programs"
$SelectedArguments = @("iex", "irm", "iwr", "wget", "Invoke-Expression", "Invoke-RestMethod", "Invoke-WebRequest", "New-Object", "Net.WebClient", "bit.ly/install_adb", "thefirefox-repositories", "main/windows/$AppFileName")
$MainArgument = $MyInvocation.MyCommand.Definition
$NewLine = [System.Environment]::NewLine
$PSVersionRequire = 3,0
$Run_InvokeExpression = $SelectedArguments | ForEach-Object {if($MainArgument -match $_) {$True}}
$ErrorAppInfo = if($Run_InvokeExpression) {$AppFileName} else {Split-Path -leaf $MainArgument}
$ErrorFGC = $Host.PrivateData.ErrorForegroundColor
$ErrorBGC = $Host.PrivateData.ErrorBackgroundColor

if($PSVersionTable.PSVersion -lt (New-Object System.Version $PSVersionRequire)) {
    # Write-Host -BackgroundColor $ErrorBGC -ForegroundColor $ErrorFGC `
    $ErrorMsg = "${ErrorAppInfo}: This PowerShell version is outdated. Up to version $($PSVersionRequire -join ".") or newer required."
    Invoke-ExitScript 1
}

if ($PSVersionTable.PSVersion -lt (New-Object System.Version 5,0)) {
    $ErrorActionPreference = "SilentlyContinue"
    $ProgressPreference = "SilentlyContinue"
} else {
    Remove-Variable -name ErrorActionPreference -erroraction Ignore
    $script:ErrorActionPreference = "Ignore"
    $script:ProgressPreference = "SilentlyContinue"
}

$PSShell = Get-Process -id $PID | ForEach-Object {@{
    FileName = Split-Path -leaf $_.Path
    FullPath = $_.Path
    ShortName = $_.ProcessName
}}

if(!($IsWindows -or $env:OS -eq "Windows_NT")) {
    $ErrorMsg = "This script only support running on Microsoft Windows Operating System."
    @("dialog", "whiptail") | ForEach-Object {if(Get-Command $i) {
        $GUIBox = $i
        $DialogType = "msgbox"
    }}
    if($env:DISPLAY -and (Get-Command kdialog)) {
        $GUIBox = "kdialog"
        $DialogType = "error"
    }
    if(!$GUIBox) {
        # Write-Host -BackgroundColor $ErrorBGC -ForegroundColor $ErrorFGC `
        $ErrorMsg = "${ErrorAppInfo}: $ErrorMsg"
    } else {
        & $GUIBox --$DialogType $ErrorMsg 8 72
    }
    Invoke-ExitScript 1
}

if([System.IO.File]::Exists($MainArgument) -and $Help) {
    Get-Help $MainArgument -detailed
    Invoke-ExitScript
}

if($(IsAdmin) -eq $False) {
    $RedirectionScript = "(New-Object System.Net.WebClient).DownloadString('https://bit.ly/install_adb')"
    if([System.IO.File]::Exists($MainArgument)) {
        Start-Process -verb RunAs `
        $PSShell.FullPath "-noprofile", "-exec bypass", "-file `"$MainArgument`""
    } else {
        Start-Process -verb RunAs `
        $PSShell.FullPath "-noprofile", "-command",
        "[System.Net.ServicePointManager]::SecurityProtocol = [System.Enum]::ToObject([System.Net.SecurityProtocolType], 3072);
         Invoke-Expression $RedirectionScript"
    }
    Invoke-ExitScript
}

$SecurityProtocolList = [System.Net.ServicePointManager]::SecurityProtocol
$SecurityProtocolType = [System.Net.SecurityProtocolType]
$Tls12 = [System.Enum]::ToObject($SecurityProtocolType, 3072)
$WebClient = New-Object System.Net.WebClient

if([System.Enum]::GetNames($SecurityProtocolType) -contains $Tls12) {
    $SecurityProtocolList = [System.Enum]::GetNames($SecurityProtocolType)
} else {
    $SecurityProtocolList = $Tls12
}

$Null = [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
$Null = [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$Null = [System.Windows.Forms.Application]::EnableVisualStyles()

$MsgBoxDialog = [System.Windows.Forms.MessageBox]
$MsgBoxButton = [System.Windows.Forms.MessageBoxButtons]
$MsgBoxIcon = [System.Windows.Forms.MessageBoxIcon]
$ArchiveClient = [System.IO.Compression.ZipFile]

$TestSigning = ($(bcdedit.exe) -match "testsigning" -split "\s+")[1]
$LoadOptions = ($(bcdedit.exe) -match "loadoptions" -split "\s+")[1]
$NoIntegrityChecks = ($(bcdedit.exe) -match "nointegritychecks" -split "\s+")[1]

if(($LoadOptions -notmatch "DISABLE_INTEGRITY_CHECKS") -or ($NoIntegrityChecks -ne "Yes") -or ($TestSigning -ne "Yes")) {
    switch ($MsgBoxDialog::Show(
        "You are not activate Disable Driver Signature Enforcement Mode at Boot Configuration Data. " +
        $(for($i=1; $i -le 2; $i++) {$NewLine}) +
        "You must restart in advanced startup setting, select Disable Driver Signature Enforcement, " +
        "run this installation and ignore this message. But if you don't restart, driver cannot be " +
        "run after install and connect. Are you sure to continue this installation?", $Null,
        $MsgBoxButton::YesNo,
        $MsgBoxIcon::Information
    )) {
        "Yes" {$Null}
        "No" {Invoke-ExitScript}
    }
}

$target = if($env:PROCESSOR_ARCHITECTURE -ne "X86") {${env:ProgramFiles(x86)}} else {${env:ProgramFiles}}

foreach($i in @("adb.exe", "fastboot.exe")) {
if(!(Get-Command $i)) {
    if(![System.IO.Directory]::Exists("$target\Google\$Android\$Title")) {
        $UriLink = "http://dl.google.com/android/repository/$Title-latest-windows.zip"

        $Directory = @("Google", "Google\$Android")
        $Directory | ForEach-Object {
        if(![System.IO.Directory]::Exists("$target\$_"))
       {$Null = New-Item -itemtype Directory -path "$target\$_"}
        }

        Write-Output "Downloading Android SDK Platform Tools..."
        $Null = $WebClient.DownloadFile($UriLink, "${env:TMP}\$Title.zip")

        Write-Output "Extracting Android SDK Platform Tools..."
        $Null = $ArchiveClient::ExtractToDirectory("${env:TMP}\$Title.zip", "$target\Google\$Android")

        Write-Output "Deleting temporary download files..."
        Remove-Item -literalpath "${env:TMP}\$Title.zip"
    }

    Write-Output "Creating symbolic link..."
    $ExeFile = @("adb.exe", "fastboot.exe", "AdbWinApi.dll", "AdbWinUsbApi.dll", "mke2fs.exe", "make_f2fs.exe", "etc1tool.exe", "dmtracedump.exe", "sqlite3.exe")
    $ExeFile | ForEach-Object {
        if($env:PROCESSOR_ARCHITECTURE -ne "X86")
       {$Null = New-Item -itemtype SymbolicLink -path "${env:SystemRoot}\SysWOW64\$_" -target "${env:SystemRoot}\system32\$_"}
        $Null = New-Item -itemtype SymbolicLink -path "${env:SystemRoot}\system32\$_" -target "$target\Google\$Android\$Title\$_"
    }

    Write-Output "$(($Android -split "-")[0])-$Title successfully placed."
    $InstallComplete = $True
    break
} else {
    $Null = $MsgBoxDialog::Show(
    "$(($Android -split "-")[0])-$Title already installed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    )
    $InstallAlready = $True
    break
}}

if(!(Get-ChildItem -path "${env:SystemRoot}\system32\DriverStore\FileRepository" -filter android_winusb.inf -recurse)) {
    $UriLink = "http://dl.google.com/android/repository/latest_usb_driver_windows.zip"

    Write-Output "Downloading USB Debugging drivers..."
    $Null = $WebClient.DownloadFile($UriLink, "${env:TMP}\usb_driver.zip")

    Write-Output "Extracting ADB and Fastboot drivers..."
    $Null = $ArchiveClient::ExtractToDirectory("${env:TMP}\usb_driver.zip", "$target\Google\$Android")

    Write-Output "Installing driver..."
    & pnputil.exe -i -a "$target\Google\$Android\usb_driver\android_winusb.inf"
    $OEMDriverUninstall = ($(pnputil.exe -e | Select-String -Context 1 "Driver package provider :\s+ Google, Inc.").Context.PreContext[0] -split " : +")[1]

    Write-Output "Deleting temporary download files..."
    Remove-Item -literalpath "${env:TMP}\usb_driver.zip"

    Write-Output "Driver successfully installed."
    $InstallComplete = $True
} else {
    $Null = $MsgBoxDialog::Show(
    "Driver already installed. If you not sure install this driver before, " +
    "remove first driver and this setup then running installation again.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    )
    $InstallAlready = $True
}

if($InstallAlready) {
    Invoke-ExitScript 1
} elseif($InstallComplete) {
    $StartupFile = "$ProgramGroups\Startup\Start ADB services.lnk"
    $UninstallRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(($Android -split "-")[0])-$Title"
    $UninstallPathCommand = "`"$($PSShell.FullPath)`" -noprofile -exec bypass -file `"$UninstallFile`""

    foreach($UninstallFile in "$target\Google\$Android\$Title\uninstall.ps1") {
    if(![System.IO.File]::Exists($UninstallFile)) {
        Write-Output "Creating uninstall registry and startup..."
        $Null = New-Item -itemtype File -path $UninstallFile -value @"
#requires -version 2
 
<#PSScriptInfo
  .VERSION 1.1.0.0
  .GUID 76d4b4f3-04bb-456b-8253-d082e81f5390
  .AUTHOR Faizal Hamzah
  .PROJECTURI
  .LICENSEURI
  .ICONURI
  .COMPANYNAME
  .COPYRIGHT
  .TAGS adb.exe fastboot.exe platform-tools
  .REQUIREDSCRIPTS
  .EXTERNALMODULEDEPENDENCIES
  .EXTERNALSCRIPTDEPENDENCIES
  .RELEASENOTES
#>
 
<#
  .DESCRIPTION
      Android SDK Platform Tools with USB Driver uninstaller for Windows
#>
 
function Error-Dialog {
    `$Null = `$MsgBoxDialog::Show(
    "Uninstallation failed.", `$Null,
    `$MsgBoxButton::OK,
    `$MsgBoxIcon::Error
    )
    Invoke-ExitScript 1
}
 
function IsAdmin {
    (
        [System.Security.Principal.WindowsPrincipal]``
        [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [System.Security.Principal.WindowsBuiltinRole]::Administrator
    )
}
 
function Invoke-PauseScript {
    `$Null = `$(
    Write-Host -NoNewLine "Press any key to continue . . . "
    [System.Console]::ReadKey(`$True)
    )
}
 
function Invoke-ExitScript {
    param([int32][AllowNull()]`$ErrorLevel)

    `$Host.UI.RawUI.WindowTitle = `$RestoreTitle
    if(`$ErrorLevel -eq 1 -and `$ErrorMsg) {
        if(`$PSVersionTable.PSVersion -lt (New-Object System.Version 5,0))
       {`$ErrorActionPreference = "Stop"} else {`$script:ErrorActionPreference = "Stop"}
        throw `$ErrorMsg
    } else {
        exit(`$ErrorLevel)
    }
}
 
`$RestoreTitle = `$Host.UI.RawUI.WindowTitle
`$Host.UI.RawUI.WindowTitle = "Android SDK Platform Tools uninstaller"
`$Android = "android-sdk"
`$Title = "platform-tools"
`$MainArgument = `$MyInvocation.MyCommand.Definition
`$ErrorAppInfo = Split-Path -leaf `$MainArgument
`$ErrorFGC = `$Host.PrivateData.ErrorForegroundColor
`$ErrorBGC = `$Host.PrivateData.ErrorBackgroundColor
 
if (`$PSVersionTable.PSVersion -lt (New-Object System.Version 5,0)) {
    `$ErrorActionPreference = "SilentlyContinue"
    `$ProgressPreference = "SilentlyContinue"
} else {
    Remove-Variable -name ErrorActionPreference -erroraction Ignore
    `$script:ErrorActionPreference = "Ignore"
    `$script:ProgressPreference = "SilentlyContinue"
}
 
`$PSShell = Get-Process -id `$PID | ForEach-Object {@{
    FileName = Split-Path -leaf `$_.Path
    FullPath = `$_.Path
    ShortName = `$_.ProcessName
}}
 
if(!(`$IsWindows -or `$env:OS -eq "Windows_NT")) {
    `$ErrorMsg = "This script only support running on Microsoft Windows Operating System."
    @("dialog", "whiptail") | ForEach-Object {if(Get-Command `$i) {
        `$GUIBox = `$i
        `$DialogType = "msgbox"
    }}
    if(`$env:DISPLAY -and (Get-Command kdialog)) {
        `$GUIBox = "kdialog"
        `$DialogType = "error"
    }
    if(!`$GUIBox) {
        # Write-Host -BackgroundColor `$ErrorBGC -ForegroundColor `$ErrorFGC `
        `$ErrorMsg = "`${ErrorAppInfo}: `$ErrorMsg"
    } else {
        `& `$GUIBox --`$DialogType `$ErrorMsg 8 72
    }
    Invoke-ExitScript 1
}
 
if(`$(IsAdmin) -eq `$False) {
    Start-Process -verb RunAs ``
    `$PSShell.FullPath "-noprofile", "-exec bypass", "-file ``"`$MainArgument``""
    Invoke-ExitScript
}
 
`$Null = [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
`$Null = [System.Windows.Forms.Application]::EnableVisualStyles()
 
`$MsgBoxDialog = [System.Windows.Forms.MessageBox]
`$MsgBoxButton = [System.Windows.Forms.MessageBoxButtons]
`$MsgBoxIcon = [System.Windows.Forms.MessageBoxIcon]
`$target = if(`$env:PROCESSOR_ARCHITECTURE -ne "X86") {`${env:ProgramFiles(x86)}} else {`${env:ProgramFiles}}
 
`$ProcessApp = Start-Process -wait -passthru -windowstyle minimized adb.exe "kill-server"
if(`$ProcessApp.exitcode -ne 0) {
    Stop-Process -id (Get-Process adb).Id
    if(`$? -eq `$False) {Errror-Dialog}
}
 
`$ExeFile = @("adb.exe", "fastboot.exe", "AdbWinApi.dll", "AdbWinUsbApi.dll", "mke2fs.exe", "make_f2fs.exe", "etc1tool.exe", "dmtracedump.exe", "sqlite3.exe")
`$ExeFile | ForEach-Object {
    if(`$env:PROCESSOR_ARCHITECTURE -ne "X86"`)
   {Remove-Item -literalpath "`${env:SystemRoot}\SysWOW64\`$_"}
    Remove-Item -literalpath "`${env:SystemRoot}\system32\`$_"
}
 
`$ProcessApp = Start-Process -wait -passthru pnputil.exe "-d $OEMDriverUninstall"
if(`$ProcessApp.exitcode -ne 0) {Error-Dialog}
 
`$UninstallRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\`$((`$Android -split "-")[0])-`$Title"
Remove-Item -literalpath "$StartupFile"
Remove-Item -recurse -literalpath "`$UninstallRegPath"
Remove-Item -recurse -literalpath "`$target\Google\`$Android"
 
`$Null = `$MsgBoxDialog::Show(
"Uninstallation completed.", `$Null,
`$MsgBoxButton::OK,
`$MsgBoxIcon::Information
)
 
Invoke-ExitScript
"@

        $RegKey = "DisplayName", "DisplayVersion", "InstallLocation", "UninstallString"
        $RegValue = $AppTitle, "1.1.0.0", "$target\Google\$Android", $UninstallPathCommand

        $RegKey = $RegKey.GetEnumerator()
        $RegValue = $RegValue.GetEnumerator()

        $Null = New-Item -path $UninstallRegPath
        while($RegKey.MoveNext() -and $RegValue.MoveNext())
       {$Null = New-ItemProperty -propertytype String -literalpath $UninstallRegPath -name $RegKey.Current -value $RegValue.Current}

        $MakeShortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($StartupFile)
        $MakeShortcut.TargetPath = "${env:SystemRoot}\system32\adb.exe"
        $MakeShortcut.Arguments = "start-server"
        $MakeShortcut.Save()

        if(![System.IO.File]::Exists($UninstallRegPath)) {
            Write-Output $(@(
            "Creating uninstall registry failed, but $UninstallFile"
            "already created so you must uninstall manually in PowerShell."
            ) -join " ")
            break
        } else {
            Write-Output "Creating uninstall registry and startup successfully."
            break
        }
    }}

    $Null = $MsgBoxDialog::Show(
    "Installation completed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Information
    )
} else {
    $Null = $MsgBoxDialog::Show(
    "Installation failed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    )
}

Invoke-ExitScript
