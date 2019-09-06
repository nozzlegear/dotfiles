function getMachineType() {
    if ($IsLinux) {
        return "Linux";
    };

    if ($IsOSX -or $IsMacOS) {
        return "macOS";
    }

    return "Windows";
}

$machineType = getMachineType;
# IsLinux, IsOSX and IsWindows are provided by PS on .NET Core, but not on vanilla Windows. 
$isNotWindows = $IsLinux -or $IsOSX;

# Alias ls to colored ls instead of PowerShell's get-childitem
Set-Alias -Name ls -Value Get-ChildItemColorFormatWide -Option AllScope
# Function ls { /bin/ls --color=tty $args }
# Set-Alias -name ls -Value BetterLs -Option AllScope
# Alias better git functions                                                                                
Function GitStatusShortcut { git status }                                                                   
set-alias -name s -value GitStatusShortcut -Option AllScope -Description "Shows the git status for the curre    nt directory."                                                                                              
git config --global --add alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit --all"

# Import and customize posh-git
# https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt 
import-module posh-git

# Make sure posh-git is at least version 1.0, or else some customization props will fail
if ($(get-module posh-git).Version.Major -lt 1) {
    write-error "Posh-Git module should be at least version 1.0. Some prompt customization options may fail."
}

$GitPromptSettings.DefaultPromptPath = '$((get-item $pwd).Name)'
$GitPromptSettings.DefaultPromptSuffix = '$(" -> " * ($nestedPromptLevel + 1))'
$GitPromptSettings.DefaultPromptWriteStatusFirst = $true
$GitPromptSettings.DefaultPromptPath.ForegroundColor = "Orange"
