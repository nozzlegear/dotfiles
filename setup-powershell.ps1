$mods = "posh-git","powershellget","psreadline","Get-ChildItemColor"
$packages = "paket.powershell"

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

$packages | % {
	echo "Installing chocolatey package $_."
	choco install "$_" -y
}

echo "Done!"
