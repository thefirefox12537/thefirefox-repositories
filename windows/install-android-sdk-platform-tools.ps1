#!/usr/bin/env pwsh
#requires -version 5

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

function Error-Dialog() {
    [void]$MsgBoxDialog::Show(
    "Installation failed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    )
    Invoke-ExitScript 1
}

function IsAdmin() {
    ([System.Security.Principal.WindowsPrincipal]`
     [System.Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([System.Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Invoke-PauseScript() {
    Write-Host -NoNewLine "Press any key to continue . . . "
    [void][System.Console]::ReadKey($True)
}

function Invoke-ExitScript([int32][AllowNull()]$ErrorLevel) {
    $host.UI.RawUI.WindowTitle = $RestoreTitle
    exit($ErrorLevel)
}

Remove-Variable ErrorActionPreference -ErrorAction Ignore
$script:ErrorActionPreference = "Ignore"
$script:ProgressPreference = "SilentlyContinue"

$RestoreTitle = [System.String]$host.UI.RawUI.WindowTitle
$host.UI.RawUI.WindowTitle = "Android SDK Platform Tools installer"
$Android = "android-sdk"
$Title = "platform-tools"
$AppFileName = "install-$Android-$Title.ps1"
$SelectedArgument = "Invoke-Expression", "iex", "bit.ly", "install_adb", "thefirefox12537/thefirefox-repositories", "main/windows/$AppFileName"
$MainArgument = $MyInvocation.MyCommand.Definition
$NewLine = [System.Environment]::NewLine
$PSVersionRequire = 5,0
$PSShell = (Get-Process -id $PID).foreach({@{
    FileName = Split-Path -leaf $_.Path
    FullPath = $_.Path
    ShortName = $_.ProcessName
}})
$Run_InvokeExpression = $SelectedArgument.foreach({if($MainArgument -match $_) {$True}})
$ErrorAppInfo = if($Run_InvokeExpression) {$AppFileName} else {Split-Path -leaf $MainArgument}
$ErrorFGC = $host.PrivateData.ErrorForegroundColor
$ErrorBGC = $host.PrivateData.ErrorBackgroundColor

if(!($IsWindows -or ($env:OS -eq "Windows_NT"))) {
    $ErrorMsg = "This script only support running on Microsoft Windows Operating System."
    @("dialog", "whiptail").foreach({if(Get-Command $i) {
        $GUIBox = $i
        $DialogType = "msgbox"
    }})
    if($env:DISPLAY -and (Get-Command kdialog)) {
        $GUIBox = "kdialog"
        $DialogType = "error"
    }
    if(!($GUIBox)) {
        Write-Host -BackgroundColor $ErrorBGC -ForegroundColor $ErrorFGC `
        "${ErrorAppInfo}: $ErrorMsg"
    } else {
        & $GUIBox --$DialogType `
        $ErrorMsg 8 72
    }
    Invoke-ExitScript 1
}

if((Test-Path -literalpath $MainArgument) -and $Help) {
    Get-Help $MainArgument -detailed
    Invoke-ExitScript
}

if($(IsAdmin) -eq $False) {
    if(Test-Path -literalpath $MainArgument) {
        Start-Process -verb RunAs `
        $PSShell.FullPath "-exec bypass", "-noprofile", "-file `"$MainArgument`""
        $ErrorLevel = 0
    } else {
        Write-Host -BackgroundColor $ErrorBGC -ForegroundColor $ErrorFGC `
        "${ErrorAppInfo}: Access denied. Run as administrator required."
        $ErrorLevel = 1
    }
    Invoke-ExitScript $ErrorLevel
}

$SvcPointMan = [System.Net.ServicePointManager]
$SecProtocol = [System.Net.SecurityProtocolType]
if([System.Environment]::OSVersion.Version -lt [System.Version]::New(6,1)) {
    if([System.Enum]::GetNames($SecProtocol) -notcontains $SecProtocol::Tls12) {
        Write-Host -BackgroundColor $ErrorBGC -ForegroundColor $ErrorFGC `
        "${ErrorAppInfo}: This script requires at least Microsoft .NET Framework 4.5."
        Invoke-ExitScript 1
    }
    $SvcPointMan::SecurityProtocol = $SecProtocol::Tls12
}

if($PSVersionTable.PSVersion -lt [System.Version]::New($PSVersionRequire)) {
    Write-Host -BackgroundColor $ErrorBGC -ForegroundColor $ErrorFGC `
    "${ErrorAppInfo}: This PowerShell version is outdated. Up to version $($PSVersionRequire -join ".") or newer required."
    Invoke-ExitScript 1
}

[void][System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Windows.Forms.Application]::EnableVisualStyles()

$MsgBoxDialog = [System.Windows.Forms.MessageBox]
$MsgBoxButton = [System.Windows.Forms.MessageBoxButtons]
$MsgBoxIcon = [System.Windows.Forms.MessageBoxIcon]
$ArchiveClient = [System.IO.Compression.ZipFile]
$WebClient = [System.Net.WebClient]::New()

$TestSigning = $($(bcdedit.exe | where{$_ -match "testsigning"}) -split "\s+")[1]
$LoadOptions = $($(bcdedit.exe | where{$_ -match "loadoptions"}) -split "\s+")[1]
$NoIntegrityChecks = $($(bcdedit.exe | where{$_ -match "nointegritychecks"}) -split "\s+")[1]
if(($LoadOptions -notmatch "DISABLE_INTEGRITY_CHECKS") -or `
   ($NoIntegrityChecks -ne "Yes") -or `
   ($TestSigning -ne "Yes")) {
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
foreach($exe in @("adb.exe", "fastboot.exe")) {
if(!(Get-Command $exe)) {
    if(!(Test-Path `
       -pathtype container `
       -literalpath "$target\Google\$Android\$Title")) {
        foreach($dir in @("Google", "Google\$Android")) {
        if(!(Test-Path `
           -pathtype container `
           -literalpath "$target\$dir")) {
            New-Item -itemtype Directory `
            -path "$target\$dir" | Out-Null
        }}

        Write-Output "Downloading Android SDK Platform Tools..."
        [void]$WebClient.DownloadFile(
        "http://dl.google.com/android/repository/$Title-latest-windows.zip",
        "${env:TMP}\$Title.zip"
        )

        Write-Output "Extracting Android SDK Platform Tools..."
        [void]$ArchiveClient::ExtractToDirectory(
        "${env:TMP}\$Title.zip", "$target\Google\$Android"
        )

        Write-Output "Deleting temporary download files..."
        Remove-Item -literalpath "${env:TMP}\$Title.zip"
    }

    Write-Output "Creating symbolic link..."
    foreach($i in @(
        "adb.exe", "fastboot.exe",
        "AdbWinApi.dll", "AdbWinUsbApi.dll",
        "mke2fs.exe", "make_f2fs.exe",
        "etc1tool.exe", "dmtracedump.exe", "sqlite3.exe"
    )) {
        New-Item -itemtype SymbolicLink `
        -path "${env:SystemRoot}\system32\$i" `
        -target "$target\Google\$Android\$Title\$i" | Out-Null
        if($env:PROCESSOR_ARCHITECTURE -ne "X86") {
            New-Item -itemtype SymbolicLink `
            -path "${env:SystemRoot}\SysWOW64\$i" `
            -target "${env:SystemRoot}\system32\$i" | Out-Null
        }
    }

    Write-Output "$(($Android -split "-")[0])-$Title successfully placed."
    $InstallComplete = $True
    break
} else {
    [void]$MsgBoxDialog::Show(
    "$(($Android -split "-")[0])-$Title already installed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    )
    $InstallAlready = $True
    break
}}

if(!(Get-ChildItem `
   -path "${env:SystemRoot}\system32\DriverStore\FileRepository" `
   -filter android_winusb.inf -recurse)) {
    Write-Output "Downloading USB Debugging drivers..."
    [void]$WebClient.DownloadFile(
    "http://dl.google.com/android/repository/latest_usb_driver_windows.zip",
    "${env:TMP}\usb_driver.zip"
    )

    Write-Output "Extracting ADB and Fastboot drivers..."
    [void]$ArchiveClient::ExtractToDirectory(
    "${env:TMP}\usb_driver.zip", "$target\Google\$Android"
    )

    Write-Output "Installing driver..."
    & pnputil.exe -i -a "$target\Google\$Android\usb_driver\android_winusb.inf"
    $OEMDriverUninstall = $(
	$(pnputil.exe -e | Select-String -Context 1 "Driver package provider :\s+ Google, Inc.").foreach({
    ($_.Context.PreContext[0] -split " : +")[1]
    }))

    Write-Output "Deleting temporary download files..."
    Remove-Item -literalpath "${env:TMP}\usb_driver.zip"

    Write-Output "Driver successfully installed."
    $InstallComplete = $True
} else {
    [void]$MsgBoxDialog::Show(
    "Driver already installed. If you not sure install this driver before, " +
    "remove first driver and this setup then running installation again.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    )
    $InstallAlready = $True
}

if($InstallAlready) {Invoke-ExitScript 1}
elseif($InstallComplete) {
    $UninstallRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(($Android -split "-")[0])-$Title"

    foreach($UninstallFile in "$target\Google\$Android\$Title\uninstall.ps1") {
    if(!(Test-Path -literalpath $UninstallFile)) {
        Write-Output "Creating uninstall registry..."
        New-Item -itemtype File `
        -path $UninstallFile `
        -value @"
#requires -version 4
 
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
 
function Error-Dialog() {
    [void]`$MsgBoxDialog::Show(
    "Uninstallation failed.", `$Null,
    `$MsgBoxButton::OK,
    `$MsgBoxIcon::Error
    )
    Invoke-ExitScript 1
}

function IsAdmin() {
    ([System.Security.Principal.WindowsPrincipal]``
     [System.Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([System.Security.Principal.WindowsBuiltinRole]::Administrator)
}
 
function Invoke-PauseScript() {
    Write-Host -NoNewLine "Press any key to continue . . . "
    [void][System.Console]::ReadKey(`$True)
}

function Invoke-ExitScript([int32][AllowNull()]`$ErrorLevel) {
    `$host.UI.RawUI.WindowTitle = `$RestoreTitle
    exit(`$ErrorLevel)
}
 
Remove-Variable ErrorActionPreference
`$script:ErrorActionPreference = "Ignore"
`$script:ProgressPreference = "SilentlyContinue"
 
`$RestoreTitle = "Android SDK Platform Tools uninstaller"
`$Android = "android-sdk"
`$Title = "platform-tools"
`$PSShell = (Get-Process -id `$PID).foreach({@{
    FileName = Split-Path -leaf `$_.Path
    FullPath = `$_.Path
    ShortName = `$_.ProcessName
}})
`$MainArgument = `$MyInvocation.MyCommand.Definition
`$ErrorAppInfo = Split-Path -leaf `$MainArgument
`$ErrorFGC = `$host.PrivateData.ErrorForegroundColor
`$ErrorBGC = `$host.PrivateData.ErrorBackgroundColor
 
if(!(`$IsWindows -or (`$env:OS -eq "Windows_NT"))) {
    `$ErrorMsg = "This script only support running on Microsoft Windows Operating System."
    @("dialog", "whiptail").foreach({if(Get-Command `$i) {
        `$GUIBox = `$i
        `$DialogType = "msgbox"
    }})
    if(`$env:DISPLAY -and (Get-Command kdialog)) {
        `$GUIBox = "kdialog"
        `$DialogType = "error"
    }
    if(!(`$GUIBox)) {Write-Host -BackgroundColor `$ErrorBGC -ForegroundColor `$ErrorFGC "`${ErrorAppInfo}: `$ErrorMsg"}
    else {`& `$GUIBox --`$DialogType `$ErrorMsg 8 72}
    Invoke-ExitScript 1
}
 
if(`$(IsAdmin) -eq `$False) {
    Start-Process -verb RunAs ``
    `$PSShell.FullPath "-exec bypass", "-noprofile", "-file ``"`$MainArgument``""
    Invoke-ExitScript
}
 
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Windows.Forms.Application]::EnableVisualStyles()

`$MsgBoxDialog = [System.Windows.Forms.MessageBox]
`$MsgBoxButton = [System.Windows.Forms.MessageBoxButtons]
`$MsgBoxIcon = [System.Windows.Forms.MessageBoxIcon]
`$target = if(`$env:PROCESSOR_ARCHITECTURE -ne "X86") {`${env:ProgramFiles(x86)}} else {`${env:ProgramFiles}}
 
Stop-Process -id (Get-Process adb).Id
if(`$? -eq `$False) {
    adb kill-server 2`>`&1 | Out-Null
    if(`$LASTEXITCODE -ne 0) {Errror-Dialog}
}
 
foreach(`$i in @(
   "adb.exe", "fastboot.exe",
   "AdbWinApi.dll", "AdbWinUsbApi.dll",
   "mke2fs.exe", "make_f2fs.exe",
   "etc1tool.exe", "dmtracedump.exe", "sqlite3.exe"
)) {
    Remove-Item -literalpath "`${env:SystemRoot}\system32\`$i"
    if(`$env:PROCESSOR_ARCHITECTURE -ne "X86"`)
   {Remove-Item -literalpath "`${env:SystemRoot}\SysWOW64\`$i"}
}
 
& pnputil.exe -d $OEMDriverUninstall
if(`$LASTEXITCODE -ne 0) {Error-Dialog}
 
`$UninstallRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\`$((`$Android -split "-")[0])-`$Title"
Remove-Item -recurse -literalpath "`$UninstallRegPath"
Remove-Item -recurse -literalpath "`$target\Google\`$Android"
 
[void]`$MsgBoxDialog::Show(
"Uninstallation completed.", `$Null,
`$MsgBoxButton::OK,
`$MsgBoxIcon::Information
)
 
Invoke-ExitScript
"@ | Out-Null

        New-Item -path $UninstallRegPath | Out-Null
        New-ItemProperty -propertytype String `
        -literalpath $UninstallRegPath `
        -name DisplayName `
        -value "Android SDK Platform Tools with USB drivers" | Out-Null
        New-ItemProperty -propertytype String `
        -literalpath $UninstallRegPath `
        -name DisplayVersion `
        -value "1.1.0.0" | Out-Null
        New-ItemProperty -propertytype String `
        -literalpath $UninstallRegPath `
        -name InstallLocation `
        -value "$target\Google\$Android" | Out-Null
        New-ItemProperty -propertytype String `
        -literalpath $UninstallRegPath `
        -name UninstallString `
        -value "`"$($PSShell.FullPath)`" -noprofile -executionpolicy bypass -file `"$UninstallFile`"" | Out-Null

        if(!(Test-Path -literalpath $UninstallRegPath)) {
            Write-Output $(@(
            "Creating uninstall registry failed, but $UninstallFile"
            "already created so you must uninstall manually in PowerShell."
            ) -join " ")
            break
        } else {
            Write-Output "Creating uninstall registry successfully."
            break
        }
    }}

    [void]$MsgBoxDialog::Show(
    "Installation completed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Information
    )
} else {
    [void]$MsgBoxDialog::Show(
    "Installation failed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    )
}

Invoke-ExitScript
