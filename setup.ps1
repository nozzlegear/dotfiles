﻿#requires -RunAsAdministrator

$packages = 
	"powershell-core",
	"poshgit",
	"sysinternals",
	"vim",
	"googlechrome",
	"docker-for-windows",
	"firefox",
	"fiddler4",
	"cmder",
	"visualstudiocode",
	"openssh",
	"gow",
	"nodejs",
	"yarn",
	"dotnetcore",
	"dotnetcore-sdk",
	"visualfsharptools",
	"nuget.commandline",
	"paket.powershell",
	"nugetpackageexplorer",
	"cshell",
	"7zip",
	"vlc",
	"jq",
	"deluge",
	"rufus",
	"autohotkey",
	"notepadplusplus",
	"youtube-dl"

# Install packages 
$packages | ForEach-Object { choco install "$_" -y }
	
# TODO: Figure out how we can tell if Powerline fonts are installed, then install them if they aren't (clone Powerline repo and run install.ps1)

# Refresh environment variables
refreshenv

# Run the node setup script which installs node build tools, node-gyp and other npm packages.
# This command is run in another instance of powershell so it gets the npm and node exes loaded
powershell.exe -Command "./setup-node.ps1"

# Set Python env variable, installed by npm windows-build-tools and used by node-gyp
setx PYTHON "$($env:HOME)/.windows-build-tools/python27/python.exe"

# Add VSCode and F# (installed by Visual Studio, not included in this script) to path
$finalPath = "$($env:PATH);"
$pathChanged = $false
$paths = 
	"C:\Program Files (x86)\Microsoft SDKs\F#\4.1\Framework\v4.0", # FSharp, installed by Visual Studio (not included in this script)
	"C:\Program Files\Microsoft VS Code\Code.exe" # VS Code, which lets us use the `code` command to open files and folders
	
$paths | ForEach-Object {
	if ("$finalPath" -notmatch "$_") {
		$finalPath += "$_;"
		$pathChanged = $true 
	}
}

if ($pathChanged -eq $true) {
	setx PATH "$finalPath"
}

# Run the powershell setup script which copies over the profile.ps1 file and installs missing modules 
powershell.exe -Command "./setup-powershell.ps1" 

# Run the docker setup script which downloads containers and starts them 
powershell.exe -Command "./setup-docker.ps1"