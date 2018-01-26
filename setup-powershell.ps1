#requires -RunAsAdministrator

$mods = "posh-git","powershellget","psreadline","Get-ChildItemColor"

echo "Copying profile.ps1 to $profile."

cp profile.ps1 $profile
. $profile

echo "Ensuring PowerShell env file exists at $psenv."

if (!(Test-Path "$psenv")) {
	touch $psenv
}

echo "Trusting PSGallery for PowerShell module installation."

Set-PSRepository PSGallery -InstallationPolicy Trusted

$mods | % { 
	echo "Installing module $_."
	install-module $_ -scope CurrentUser -SkipPublisherCheck 
}

# Check if the colortool exists and clone it to this repository if not
if (! (Test-path "colortool")) {
	Invoke-WebRequest -uri "https://github.com/Microsoft/console/releases/download/1708.14008/colortool.zip" -OutFile "colortool.zip"
	Expand-Archive "colortool.zip" -DestinationPath "colortool"
}

if (! (Test-Path "colortool/schemes/Dracula.itermcolors")) {
	Invoke-WebRequest -uri "https://raw.githubusercontent.com/dracula/iterm/fb852408c1320069a416d734eca876e82ac4cc43/Dracula.itermcolors" -OutFile "colortool/schemes/Dracula.itermcolors"
}

& "colortool/colortool.exe" -b "Dracula"

echo "Colortool has set console theme to Dracula. It does not currently handle setting background colors. To set the Dracula background color, edit the console's Default settings and set Background color to 39 Red, 41 Green, 54 Blue."

if ($(get-module psreadline | select version) -notmatch "2.") {
	echo "Module PSReadline versions less than 2.0.0 contain a bug when used with Powershell 6.0 that disables CTRL+V, CTRL+C, CTRL+Z keybindings. Installing PSReadline 2.0+."
	Install-Module PSReadline -AllowPrerelease -AllowClobber -Force -SkipPublisherCheck -MinimumVersion "2.0.0"
	echo "You'll need to restart PowerShell to load the copy/paste/undo keybinding fix."
}
