﻿<##################################################################################################

    Description
    ===========

	- This script does the following - 
		- installs yarn
		- installs specified yarn packages

	- This script generates logs in the following folder - 
		- %ALLUSERSPROFILE%\YarnPackageInstaller-{TimeStamp}\Logs folder.


    Usage examples
    ==============
    
    Powershell -executionpolicy bypass -file YarnPackageInstaller.ps1


    Pre-Requisites
    ==============

    - Ensure that the powershell execution policy is set to unrestricted (@TODO).


    Known issues / Caveats
    ======================
    
    - No known issues.


    Coming soon / planned work
    ==========================

    - N/A.    

##################################################################################################>

#
# Optional arguments to this script file.
#

Param(
    # comma or semicolon separated list of Yarn packages.
    [ValidateNotNullOrEmpty()]
    [string]
    $RawPackagesList
)

##################################################################################################

#
# Powershell Configurations
#

# Note: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.  
$ErrorActionPreference = "Stop"

# Ensure that current process can run scripts. 
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force 

###################################################################################################

#
# Custom Configurations
#

$YarnPackageInstallerFolder = Join-Path $env:ALLUSERSPROFILE -ChildPath $("YarnPackageInstaller-" + [System.DateTime]::Now.ToString("yyyy-MM-dd-HH-mm-ss"))

# Location of the log files
$ScriptLog = Join-Path -Path $YarnPackageInstallerFolder -ChildPath "YarnPackageInstaller.log"
$YarnInstallLog = Join-Path -Path $YarnPackageInstallerFolder -ChildPath "YarnInstall.log"

##################################################################################################

# 
# Description:
#  - Displays the script argument values (default or user-supplied).
#
# Parameters:
#  - N/A.
#
# Return:
#  - N/A.
#
# Notes:
#  - Please ensure that the Initialize() method has been called at least once before this 
#    method. Else this method can only write to console and not to log files. 
#

function DisplayArgValues
{
    WriteLog '========== Configuration =========='
    WriteLog "RawPackagesList : $RawPackagesList"
    WriteLog '========== Configuration =========='
}

##################################################################################################

# 
# Description:
#  - Displays paths configured for the current environment
#
# Parameters:
#  - N/A.
#
# Return:
#  - N/A.
#
# Notes:
#  - 
#

function DisplayPathValues
{
    WriteLog '========== Paths =========='
    ([System.Environment]::GetEnvironmentVariable("path") -split ";") | % { if ($_) { WriteLog $_ } }
    WriteLog '========== Paths =========='
}

##################################################################################################

# 
# Description:
#  - Creates the folder structure which'll be used for dumping logs generated by this script and
#    the logon task.
#
# Parameters:
#  - N/A.
#
# Return:
#  - N/A.
#
# Notes:
#  - N/A.
#

function InitializeFolders
{
    if ($false -eq (Test-Path -Path $YarnPackageInstallerFolder))
    {
        New-Item -Path $YarnPackageInstallerFolder -ItemType directory | Out-Null
    }
}

##################################################################################################

# 
# Description:
#  - Writes specified string to the console as well as to the script log (indicated by $ScriptLog).
#
# Parameters:
#  - $message: The string to write.
#
# Return:
#  - N/A.
#
# Notes:
#  - N/A.
#

function WriteLog
{
    Param(
        <# Can be null or empty #>
        [string]$Message,
        [switch]$LogFileOnly
    )

    $timestampedMessage = "[$([System.DateTime]::Now)] $Message" | % {
        if (-not $LogFileOnly)
        {
            Write-Host -Object $_
        }
        Out-File -InputObject $_ -FilePath $ScriptLog -Append
    }
}

##################################################################################################

# 
# Description:
#  - Installs the Yarn package manager.
#
# Parameters:
#  - N/A.
#
# Return:
#  - If installation is successful, then nothing is returned.
#  - Else a detailed terminating error is thrown.
#
# Notes:
#  - @TODO: Write to $YarnInstallLog log file.
#  - @TODO: Currently no errors are being written to the log file ($YarnInstallLog). This needs to be fixed.
#

function InstallYarn
{
    Param(
        [ValidateNotNullOrEmpty()] $YarnInstallLog
    )

    WriteLog 'Installing Chocolatey ...'
    Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null
    WriteLog 'Success.'

    WriteLog 'Installing Yarn ...'
    choco install yarn --force --yes --acceptlicense --verbose --allow-empty-checksums | Out-Null
    WriteLog 'Success.'

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")

    DisplayPathValues
}

##################################################################################################

#
# Description:
#  - Installs the specified Yarn packages on the machine.
#
# Parameters:
#  - N/A.
#
# Return:
#  - N/A.
#
# Notes:
#  - N/A.
#

function InstallPackages
{
    Param(
        [ValidateNotNullOrEmpty()][string] $packagesList
    )

    $separator = @(";",",")
    $splitOption = [System.StringSplitOptions]::RemoveEmptyEntries
    $packages = $packagesList.Trim().Split($separator, $splitOption)

    if (0 -eq $packages.Count)
    {
        WriteLog 'No packages were specified. Exiting.'
        return        
    }

    $postBootKey = [System.IO.Path]::GetFileName($YarnPackageInstallerFolder)
    $postBootScript = [System.IO.Path]::ChangeExtension($ScriptLog, ".ps1")

    Out-File -InputObject "`"===========================================================================================`"" -FilePath $postBootScript -Append
    Out-File -InputObject "`"     _                          ____             _____         _     _          _          `"" -FilePath $postBootScript -Append
    Out-File -InputObject "`"    / \    _____   _ _ __ ___  |  _ \  _____   _|_   _|__  ___| |_  | |    __ _| |__  ___  `"" -FilePath $postBootScript -Append
    Out-File -InputObject "`"   / _ \  |_  / | | | '__/ _ \ | | | |/ _ \ \ / / | |/ _ \/ __| __| | |   / _' | '_ \/ __| `"" -FilePath $postBootScript -Append
    Out-File -InputObject "`"  / ___ \  / /| |_| | | |  __/ | |_| |  __/\ V /  | |  __/\__ \ |_  | |__| (_| | |_) \__ \ `"" -FilePath $postBootScript -Append
    Out-File -InputObject "`" /_/   \_\/___|\__,_|_|  \___| |____/ \___| \_/   |_|\___||___/\__| |_____\__._|_.__/|___/ `"" -FilePath $postBootScript -Append
    Out-File -InputObject "`"===========================================================================================`"" -FilePath $postBootScript -Append
    Out-File -InputObject "function ToArray { begin { `$output = @(); } process { `$output += `$_; } end { return ,`$output; } }" -FilePath $postBootScript -Append
    Out-File -InputObject "try {" -FilePath $postBootScript -Append
    Out-File -InputObject "if (`$PSCommandPath) { Start-Transcript -Path ([System.IO.Path]::ChangeExtension(`$PSCommandPath, `".log`")) -Append -ErrorAction SilentlyContinue | Out-Null }" -FilePath $postBootScript -Append
    Out-File -InputObject "`"Installing Yarn & package/s as '`$(whoami)' ...`"" -FilePath $postBootScript -Append

    foreach ($package in $packages)
    {
        $package = $package.Trim()
        $command = "yarn global add $package --force --non-interactive *>`$null"

        Out-File -InputObject "`"``n>>> Installing Yarn package '$package' ...`"" -FilePath $postBootScript -Append
        Out-File -InputObject $command -FilePath $postBootScript -Append
        Out-File -InputObject "`"Success`"" -FilePath $postBootScript -Append
    }

    Out-File -InputObject "`"``n>>> Adding Yarn bin folder to path ...``n`$(yarn global bin)`"" -FilePath $postBootScript -Append
    Out-File -InputObject "`$path = (([System.Environment]::GetEnvironmentVariable(`"path`", `"user`") | Out-String) -split `";`") | ? { -not [string]::IsNullOrWhiteSpace(`$_) } | ToArray" -FilePath $postBootScript -Append
    Out-File -InputObject "`$path += `"`$((yarn global bin | Out-String) -replace `"``n|``r`")\`"" -FilePath $postBootScript -Append
    Out-File -InputObject "[System.Environment]::SetEnvironmentVariable(`"path`", `"`$(`$path -join `";`");`", `"user`")" -FilePath $postBootScript -Append

    Out-File -InputObject "`"``n>>> Dump user environment path (`$(whoami)) ...`"" -FilePath $postBootScript -Append
    Out-File -InputObject "([System.Environment]::GetEnvironmentVariable(`"path`", `"user`") | Out-String).Split(`";`", [System.StringSplitOptions]::RemoveEmptyEntries)" -FilePath $postBootScript -Append

    Out-File -InputObject "} catch {" -FilePath $postBootScript -Append
    Out-File -InputObject "`"ERROR: `$(`$_.Exception.Message)`"" -FilePath $postBootScript -Append
    Out-File -InputObject "} finally {" -FilePath $postBootScript -Append
    Out-File -InputObject "Stop-Transcript -ErrorAction SilentlyContinue `n }" -FilePath $postBootScript -Append

    Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "!$postBootKey" -Value "powershell.exe -ExecutionPolicy bypass `"& $postBootScript`""
}

##################################################################################################

#
# 
#

try
{
    #
    InitializeFolders

    #
    DisplayArgValues
    
    # install the Yarn package manager
    InstallYarn -YarnInstallLog $YarnInstallLog

    # install the specified packages
    InstallPackages -packagesList $RawPackagesList
}
catch
{
    $errMsg = $Error[0].Exception.Message
    if ($errMsg)
    {
        WriteLog -Message "ERROR: $errMsg" -LogFileOnly
    }

    # IMPORTANT NOTE: We rely on Artifactsfile.ps1 to manage the workflow. It is there where we need to
    # ensure an exit code is correctly sent back to the calling process. From here, all we need to do is
    # throw so that startYarn.ps1 can handle the state correctly.
    throw
}
