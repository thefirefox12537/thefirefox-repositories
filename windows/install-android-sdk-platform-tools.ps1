#requires -version 4

<#PSScriptInfo
  .VERSION 1.0.0.0
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
      Android Platform Tools with USB Driver installer for Windows
#>

param([switch][alias('h')]$Help)
$AppFileName = "install-android-sdk-platform-tools.ps1"
$Github_Site = "github.com"
$RawGithub = "raw.githubusercontent.com"
$RepositoryName = "thefirefox12537/thefirefox-repositories"
$RepositoryBranch = "main/windows/$AppFileName"
$Android = "android-sdk"
$Title = "platform-tools"
$PwshShell = (Get-Process -id $PID).Path
$IsAdmin = if($IsWindows -or ($env:OS -eq "Windows_NT")) {
[System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent() |
foreach{$_.IsInRole([System.Security.Principal.WindowsBuiltinRole]::Administrator)}
} elseif($(whoami) -eq "root") {$true} else {$false}
$Run_InvokeExpression = foreach($iex in @("Invoke-Expression", "invoke-expression", "iex")) {@(
"bit.ly/install_adb", "$Github_Site/$RepositoryName/raw/$RepositoryBranch", "$RawGithub/$RepositoryName/$RepositoryBranch"
) |
foreach{if(($MyInvocation.MyCommand.Definition -match $iex) -and ($MyInvocation.MyCommand.Definition -match $_) {$true}}}
$ErrorAppInfo = if($Run_InvokeExpression) {$AppFileName} else {Split-Path -Leaf "$($MyInvocation.MyCommand.Definition)"}

if(!($IsWindows -or ($env:OS -eq "Windows_NT"))) {
    $ErrorMsg = "This script only support running on Microsoft Windows Operating System."
    foreach($i in @("dialog", "whiptail")) {if(Get-Command $i -ErrorAction Ignore) {$GUIBox = $i; $DialogType = "--msgbox"}}
    if($env:DISPLAY -and (Get-Command kdialog -ErrorAction Ignore)) {$GUIBox = "kdialog"; $DialogType = "--error"}
    if(!($GUIBox)) {Write-Error $ErrorMsg}
    else {& $GUIBox $DialogType $ErrorMsg 8 72}
    exit
}

$NewLine = [System.Environment]::NewLine

if($Help) {Get-Help "$($MyInvocation.MyCommand.Definition)" -detailed; exit 0}
if($IsAdmin -eq $false) {
    if(Test-Path $MyInvocation.MyCommand.Definition) {
        Start-Process -verb RunAs `
        "$PwshShell" "/noprofile /executionpolicy unrestricted /file `"$($MyInvocation.MyCommand.Definition)`""
    } else {
        Write-Host -ForegroundColor red "${ErrorAppInfo}: This command cannot be run as standard user. You must running as administrator first."
    }
    if($Run_InvokeExpression) {pause}
    exit 1
}

$availableExecutionPolicy = @("Unrestricted", "RemoteSigned", "ByPass")
if((Get-ExecutionPolicy).ToString() -notin $availableExecutionPolicy) {
    Write-Host -ForegroundColor red $(@(
    "${ErrorAppInfo}: "
    "PowerShell requires an execution policy in [$($availableExecutionPolicy -join ", ")] to run this script. "
    "For example, to set the execution policy to 'RemoteSigned' please run PowerShell as Administrator and type : $($NewLine)"
    "'Set-ExecutionPolicy RemoteSigned'"
    ) -join " ")
    if($Run_InvokeExpression) {pause}
    exit 1
}

$SvcPointMan = [System.Net.ServicePointManager]
$SecProtocol = [System.Net.SecurityProtocolType]
if([System.Environment]::OSVersion.Version -lt (New-Object Version 6,1)) {
    if([System.Enum]::GetNames($SecProtocol) -notcontains "Tls12") {
        Write-Host -ForegroundColor red "${ErrorAppInfo}: This script requires at least Microsoft .NET Framework 4.5."
        if($Run_InvokeExpression) {pause}
        exit 1
    }
    $SvcPointMan::SecurityProtocol = $SecProtocol::Tls12
}
foreach($variable in @("ProgressPreference", "ErrorActionPreference"))
{Set-Variable $variable "SilentlyContinue"}
Add-Type -Assembly System.Windows.Forms | Out-Null
Add-Type -Assembly System.IO.Compression.FileSystem | Out-Null
$MsgBoxDialog = [System.Windows.Forms.MessageBox]
$MsgBoxButton = [System.Windows.Forms.MessageBoxButtons]
$MsgBoxIcon = [System.Windows.Forms.MessageBoxIcon]
$ArchiveClient = [System.IO.Compression.ZipFile]
$WebClient = New-Object System.Net.WebClient
$TestSigning = $($(bcdedit | where{$_ -match "testsigning"}) -split "\s+")[1]
$LoadOptions = $($(bcdedit | where{$_ -match "loadoptions"}) -split "\s+")[1]
$NoIntegrityChecks = $($(bcdedit | where{$_ -match "nointegritychecks"}) -split "\s+")[1]
if(($LoadOptions -notmatch "DISABLE_INTEGRITY_CHECKS") -or `
   ($NoIntegrityChecks -ne "Yes") -or `
   ($TestSigning -ne "Yes")) {
    $Options = $MsgBoxDialog::Show(@(
    "You are not activate Disable Driver Signature Enforcement Mode at Boot Configuration Data. $($NewLine)"
    "You must restart in advanced startup setting, select Disable Driver Signature Enforcement, "
    "run this installation and ignore this message. But if you don't restart, driver cannot be "
    "run after install and connect. Are you sure to continue this installation?" -join $NewLine), $Null,
    $MsgBoxButton::YesNo,
    $MsgBoxIcon::Information
    )
    if($Options -eq "No") {
        if($Run_InvokeExpression) {pause}
        exit
    }
}
$target = $(
if($env:PROCESSOR_ARCHITECTURE -ne "X86") {${env:ProgramFiles(x86)}}
else {${env:ProgramFiles}}
)
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
        $WebClient.DownloadFile(
        "http://dl.google.com/android/repository/$Title-latest-windows.zip",
        "${env:TMP}\$Title.zip"
        )
        Write-Output "Extracting Android SDK Platform Tools..."
        $ArchiveClient::ExtractToDirectory(
        "${env:TMP}\$Title.zip", "$target\Google\$Android"
        ) | Out-Null
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
    $InstallComplete = $true
    break
} else {
    $MsgBoxDialog::Show(
    "$(($Android -split "-")[0])-$Title already installed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    ) | Out-Null
    $InstallAlready = $true
    break
}}
if(!(Get-ChildItem `
   -path "${env:SystemRoot}\system32\DriverStore\FileRepository" `
   -filter android_winusb.inf -recurse)) {
    Write-Output "Downloading USB Debugging drivers..."
    $WebClient.DownloadFile(
    "http://dl.google.com/android/repository/latest_usb_driver_windows.zip",
    "${env:TMP}\usb_driver.zip"
    )
    Write-Output "Extracting ADB and Fastboot drivers..."
    $ArchiveClient::ExtractToDirectory(
    "${env:TMP}\usb_driver.zip", "$target\Google\$Android"
    ) | Out-Null
    Write-Output "Installing driver..."
    pnputil -i -a "$target\Google\$Android\usb_driver\android_winusb.inf"
    $OEMDriverUninstall = $(pnputil -e |
    Select-String -Context 1 "Driver package provider :\s+ Google, Inc." |
    foreach{($_.Context.PreContext[0] -split " : +")[1]})
    Write-Output "Deleting temporary download files..."
    Remove-Item -literalpath "${env:TMP}\usb_driver.zip"
    Write-Output "Driver successfully installed."
    $InstallComplete = $true
} else {
    $MsgBoxDialog::Show(@(
    "Driver already installed. If you not sure install this driver before, "
    "remove first driver and this setup then running installation again." -join $NewLine), $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    ) | Out-Null
    $InstallAlready = $true
}
if($InstallAlready) {if($Run_InvokeExpression) {return} else {exit}}
elseif($InstallComplete) {
    $UninstallRegPath =
    "HKLM:\SOFTWARE\" +
    "Microsoft\Windows\CurrentVersion\Uninstall\$(($Android -split "-")[0])-$Title"
    foreach($UninstallFile in "$target\Google\$Android\$Title\uninstall.ps1") {
    if(!(Test-Path -literalpath $UninstallFile)) {
        Write-Output "Creating uninstall registry..."
        New-Item -itemtype File `
        -path $UninstallFile `
        -value @"
#requires -version 4
<#PSScriptInfo
  .VERSION 1.0.0.0
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
      Android Platform Tools with USB Driver uninstaller for Windows
#>
function Error-Dialog() {
    `$MsgBoxDialog::Show(
    "Uninstallation failed.", `$Null,
    `$MsgBoxButton::OK,
    `$MsgBoxIcon::Error
    ) | Out-Null
    exit 1
}
if(!(`$IsWindows -or (`$env:OS -eq "Windows_NT"))) {
    `$ErrorMsg = "This script only support running on Microsoft Windows Operating System."
    foreach(`$i in @("dialog", "whiptail")) {if(Get-Command `$i -ErrorAction Ignore) {`$GUIBox = `$i; `$DialogType = "--msgbox"}}
    if(`$env:DISPLAY -and (Get-Command kdialog -ErrorAction Ignore)) {`$GUIBox = "kdialog"; `$DialogType = "--error"}
    if(!(`$GUIBox)) {Write-Error `$ErrorMsg}
    else {`& `$GUIBox `$DialogType `$ErrorMsg 8 72}
    exit 1
}
`$Android = "android-sdk"
`$Title = "platform-tools"
`$PwshShell = (Get-Process -id `$PID).Path
[System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent() |
foreach{if(`$_.IsInRole([System.Security.Principal.WindowsBuiltinRole]::Administrator) -eq `$false) {
    Start-Process -verb RunAs ``
    "`$PwshShell" "/noprofile /executionpolicy unrestricted /file ``"`$(`$MyInvocation.MyCommand.Definition)``""
    exit
}}
`$target = `$(
if(`$env:PROCESSOR_ARCHITECTURE -ne "X86") {`${env:ProgramFiles(x86)}}
else {`${env:ProgramFiles}}
)
Add-Type -Assembly System.Windows.Forms | Out-Null
`$MsgBoxDialog = [System.Windows.Forms.MessageBox]
`$MsgBoxButton = [System.Windows.Forms.MessageBoxButtons]
`$MsgBoxIcon = [System.Windows.Forms.MessageBoxIcon]
Stop-Process -id (Get-Process adb).Id
if(`$? -eq `$false) {
    adb kill-server
    if(`$LASTEXITCODE -ne 0) {Errror-Dialog}
}
foreach(`$i in @(
  "adb.exe", "fastboot.exe",
  "AdbWinApi.dll", "AdbWinUsbApi.dll",
  "mke2fs.exe", "make_f2fs.exe",
  "etc1tool.exe", "dmtracedump.exe", "sqlite3.exe"
)) {
    Remove-Item -literalpath "`${env:SystemRoot}\system32\`$i"
    if(`$env:PROCESSOR_ARCHITECTURE -ne "X86"`) {
        Remove-Item -literalpath "`${env:SystemRoot}\SysWOW64\`$i"
    }
}
pnputil -d $OEMDriverUninstall
if(`$LASTEXITCODE -ne 0) {Error-Dialog}
`$UninstallRegPath =
"HKLM:\SOFTWARE\" +
"Microsoft\Windows\CurrentVersion\Uninstall\`$((`$Android -split "-")[0])-`$Title"
Remove-Item -recurse -literalpath "`$UninstallRegPath"
Remove-Item -recurse -literalpath "`$target\Google\`$Android"
`$MsgBoxDialog::Show(
"Uninstallation completed.", `$Null,
`$MsgBoxButton::OK,
`$MsgBoxIcon::Information
) | Out-Null
exit 0
"@ | Out-Null
        New-Item -path $UninstallRegPath | Out-Null
        New-ItemProperty -propertytype String `
        -literalpath $UninstallRegPath `
        -name DisplayName `
        -value "Android Platform Tools with USB drivers" | Out-Null
        New-ItemProperty -propertytype String `
        -literalpath $UninstallRegPath `
        -name DisplayVersion `
        -value "1.0.0.0" | Out-Null
        New-ItemProperty -propertytype String `
        -literalpath $UninstallRegPath `
        -name InstallLocation `
        -value "$target\Google\$Android" | Out-Null
        New-ItemProperty -propertytype String `
        -literalpath $UninstallRegPath `
        -name UninstallString `
        -value "`"$PwshShell`" -noprofile -executionpolicy unrestricted -file `"$UninstallFile`"" | Out-Null
        if(!(Test-Path -literalpath $UninstallRegPath)) {
            Write-Output $(@(
            "Creating uninstall registry failed, but $UninstallFile "
            "already created so you must uninstall manually in PowerShell."
            ) -join " ")
            break
        } else {
            Write-Output "Creating uninstall registry successfully."
            break
        }
    }}
    $MsgBoxDialog::Show(
    "Installation completed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Information
    ) | Out-Null
} else {
    $MsgBoxDialog::Show(
    "Installation failed.", $Null,
    $MsgBoxButton::OK,
    $MsgBoxIcon::Error
    ) | Out-Null
}
exit
