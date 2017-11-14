write-host "Loading powershell profile.";

# Powershell lacks a null-coalescing (??) operator, so this function makes up for it.
function Coalesce($a, $b) { if ($a -ne $null) { $a } else { $b } }

# Easily add a property to a custom object
function AddPropTo-Object($obj, $propName, $value) {
    $obj | Add-Member -type NoteProperty -name $propName -value $value;

    return $obj;
}

Set-Alias -name ?? -value Coalesce;
Set-Alias -name prop -value AddPropTo-Object;

# Save the profile name for use when copying between $Profile and $onedrive/profile
$profileName = (get-item $profile).Name;
$profileFolder = split-path $profile;
$username = ?? $env:username $(whoami);

function getMachineType() {
    if ($IsLinux) {
        return "Linux";
    };

    if ($IsOSX) {
        return "macOS";
    }

    return "Windows";
}

$machineType = getMachineType;
# IsLinux, IsOSX and IsWindows are provided by PS on .NET Core, but not on vanilla Windows. 
$isNotWindows = $IsLinux -or $IsOSX;

# Customize the posh-git prompt to only show the current folder name + git status
function prompt {
    $origLastExitCode = $LASTEXITCODE;
    $folderName = (get-item $pwd).Name;
    # $emoji = [char]::ConvertFromUtf32(0x1F914);  

    if ($isNotWindows) {
        # A bug in PSReadline on .NET Core makes all colored write-host output in prompt 
        # function, including write-vcsstatus, echo twice.
        # https://github.com/PowerShell/PowerShell/issues/1897
        # https://github.com/lzybkr/PSReadLine/issues/468
        "$folderName => ";
    }
    else {
        write-host "$folderName" -nonewline -foregroundcolor green;
        Write-VcsStatus;
        " => ";
    }

    # Yarn and msbuild have a habit of corrupting console colors when ctrl+c-ing them. Reset colors on each prompt.
    [Console]::ResetColor();

    $LASTEXITCODE = $origLastExitCode;
}

# Load the psenv file
$psenv = "$(Split-Path $profile)/psenv.ps1";

if (! (Test-Path $psenv)) {
    # Create the env file and swallow the output
    New-Item $psenv | out-null;
}

. $psenv;

function findFolder($folderName) {
    $basicDrive = $null;

    foreach ($drive in "~", "C:", "D:") {
        if (Test-Path "$drive/$folderName") {
            $basicDrive = $drive;

            break;
        }
    }

    if ($basicDrive -ne $null) {
        return "$basicDrive/$folderName";
    }

    if ($isNotWindows) {
        function searchTopFolder($folderName) {
            $drivePath = $null;

            if (Test-Path $folderName) {
                # Using foreach here instead of piping to %, because breaking in a % pipe stops the function itself, not the %.
                foreach ($drive in gci "/media/$username") {
                    if (Test-Path "$($drive.FullName)/$folderName") {
                        $drivePath = $drive.FullName;

                        break;
                    }
                }

                if ($drivePath -ne $null) {
                    return "$drivePath/$folderName";
                }
            }

            return $null;
        }

        return ?? (searchTopFolder "/media/$username") (searchTopFolder "/mnt")
    }

    # Don't set the value if it wasn't found.
    return $null;
}

# Find OneDrive, Dropbox and Source folders
$onedrive = findFolder "OneDrive";
$dropbox = findFolder "Dropbox";
$source = findFolder "source";

# Function to reset colors when they get messed up by some program (e.g. react native)
function Reset-Colors {
    [Console]::ResetColor();
    echo "Console colors have been reset.";
}

Set-Alias -Name resetColors -Value Reset-Colors -Option AllScope;

# Sudo alias, from http://www.exitthefastlane.com/2009/08/sudo-for-powershell.html
function elevate-process {
    $file, [string]$arguments = $args;
    $psi = new-object System.Diagnostics.ProcessStartInfo $file;
    $psi.Arguments = $arguments;
    $psi.Verb = "runas";
    $psi.WorkingDirectory = get-location;
    [System.Diagnostics.Process]::Start($psi);
} 

Set-Alias sudo elevate-process;

# Extra PS goodies, inspired by https://github.com/mikemaccana/powershell-profile
function uptime {
    if ($isNotWindows) {
        bash -c "uptime";

        return;
    }

    Get-WmiObject win32_operatingsystem | select csname, @{LABEL = 'LastBootUpTime';
        EXPRESSION = {$_.ConverttoDateTime($_.lastbootuptime)}
    }
}

function fromHome($Path) {
    $Path.Replace("$home", "~")
}

# http://mohundro.com/blog/2009/03/31/quickly-extract-files-with-powershell/
function unarchive([string]$file, [string]$outputDir = '') {
    if (-not (Test-Path $file)) {
        $file = Resolve-Path $file
    }

    if ($outputDir -eq '') {
        $outputDir = [System.IO.Path]::GetFileNameWithoutExtension($file)
    }

    7z e "-o$outputDir" $file
}

# http://stackoverflow.com/questions/39148304/fuser-equivalent-in-powershell/39148540#39148540
function fuser($relativeFile) {
    $file = Resolve-Path $relativeFile

    echo "Looking for processes using $file"

    if ($isNotWindows) {
        sudo bash -c "fuser $file.Path";

        return;
    }

    foreach ( $Process in (Get-Process)) {
        foreach ( $Module in $Process.Modules) {
            if ( $Module.FileName -like "$file*" ) {
                $Process | select id, path
            }
        }
    }
}

function findfile($name) {
    ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
        $place_path = $_.directory
        echo "${place_path}\${_}"
    }
}

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function unzip ($file) {
    $dirname = (Get-Item $file).Basename
    echo("Extracting", $file, "to", $dirname)
    New-Item -Force -ItemType directory -Path $dirname
    expand-archive $file -OutputPath $dirname -ShowProgress
}

# https://gist.github.com/aroben/5542538
function pstree {
    $ProcessesById = @{}
    foreach ($Process in (Get-WMIObject -Class Win32_Process)) {
        $ProcessesById[$Process.ProcessId] = $Process
    }

    $ProcessesWithoutParents = @()
    $ProcessesByParent = @{}
    foreach ($Pair in $ProcessesById.GetEnumerator()) {
        $Process = $Pair.Value

        if (($Process.ParentProcessId -eq 0) -or !$ProcessesById.ContainsKey($Process.ParentProcessId)) {
            $ProcessesWithoutParents += $Process
            continue
        }

        if (!$ProcessesByParent.ContainsKey($Process.ParentProcessId)) {
            $ProcessesByParent[$Process.ParentProcessId] = @()
        }
        $Siblings = $ProcessesByParent[$Process.ParentProcessId]
        $Siblings += $Process
        $ProcessesByParent[$Process.ParentProcessId] = $Siblings
    }

    function Show-ProcessTree([UInt32]$ProcessId, $IndentLevel) {
        $Process = $ProcessesById[$ProcessId]
        $Indent = " " * $IndentLevel
        if ($Process.CommandLine) {
            $Description = $Process.CommandLine
        }
        else {
            $Description = $Process.Caption
        }

        Write-Output ("{0,6}{1} {2}" -f $Process.ProcessId, $Indent, $Description)
        foreach ($Child in ($ProcessesByParent[$ProcessId] | Sort-Object CreationDate)) {
            Show-ProcessTree $Child.ProcessId ($IndentLevel + 4)
        }
    }

    Write-Output ("{0,6} {1}" -f "PID", "Command Line")
    Write-Output ("{0,6} {1}" -f "---", "------------")

    foreach ($Process in ($ProcessesWithoutParents | Sort-Object CreationDate)) {
        Show-ProcessTree $Process.ProcessId 0
    }
}

# Unix-touch
function unixtouch($file) {
    if ($isNotWindows) {
        bash -c "touch $file";

        return;
    }

    "" | Out-File $file -Encoding ASCII
}

if (-not $isNotWindows) {
    Set-Alias -Name touch -Value unixtouch -Option AllScope
}

# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# https://gist.github.com/ecampidoglio/1635952
function Out-Diff {
    <#
	.Synopsis
		Redirects a Universal DIFF encoded text from the pipeline to the host using colors to highlight the differences.
	.Description
		Helper function to highlight the differences in a Universal DIFF text using color coding.
	.Parameter InputObject
		The text to display as Universal DIFF.
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSObject]$InputObject
    )
    Process {
        $contentLine = $InputObject | Out-String
        if ($contentLine -match "^Index:") {
            Write-Host $contentLine -ForegroundColor Cyan -NoNewline
        }
        elseif ($contentLine -match "^(\+|\-|\=){3}") {
            Write-Host $contentLine -ForegroundColor Gray -NoNewline
        }
        elseif ($contentLine -match "^\@{2}") {
            Write-Host $contentLine -ForegroundColor Gray -NoNewline
        }
        elseif ($contentLine -match "^\+") {
            Write-Host $contentLine -ForegroundColor Green -NoNewline
        }
        elseif ($contentLine -match "^\-") {
            Write-Host $contentLine -ForegroundColor Red -NoNewline
        }
        else {
            Write-Host $contentLine -NoNewline
        }
    }
}

# https://github.com/JRJurman/PowerLS
function PowerLS {
    <#
	.Synopsis
	Powershell unix-like ls
	Written by Jesse Jurman (JRJurman)

	.Description
	A colorful ls

	.Parameter Redirect
	The first month to display.

	.Example
	# List the current directory
	PowerLS

	.Example
	# List the parent directory
	PowerLS ../
	#>
    param(
        [string]$redirect = "."
    )
    write-host "" # add newline at top

    # get the console buffersize
    $buffer = Get-Host
    $bufferwidth = $buffer.ui.rawui.buffersize.width

    # get all the files and folders
    $childs = Get-ChildItem $redirect

    # get the longest string and get the length
    $lnStr = $childs | select-object Name | sort-object { "$_".length } -descending | select-object -first 1
    $len = $lnStr.name.length

    # keep track of how long our line is so far
    $count = 0

    # extra space to give some breather space
    $breather = 4

    # for every element, print the line
    foreach ($e in $childs) {

        $newName = $e.name + (" " * ($len - $e.name.length + $breather))
        $count += $newName.length

        # determine color we should be printing
        # Blue for folders, Green for files, and Gray for hidden files
        if (($newName -match "^\..*$") -and (Test-Path ($redirect + "\" + $e) -pathtype container)) {
            #hidden folders
            $newName = $e.name + "\" + (" " * ($len - $e.name.length + $breather - 1))
            write-host $newName -nonewline -foregroundcolor darkcyan
        }
        elseif (Test-Path ($redirect + "\" + $e) -pathtype container) {
            #normal folders
            $newName = $e.name + "\" + (" " * ($len - $e.name.length + $breather - 1))
            write-host $newName -nonewline -foregroundcolor cyan
        }
        elseif ($newName -match "^\..*$") {
            #hidden files
            write-host $newName -nonewline -foregroundcolor darkgray
        }
        elseif ($newName -match "\.[^\.]*") {
            #normal files
            write-host $newName -nonewline -foregroundcolor darkyellow
        }
        else {
            #others...
            write-host $newName -nonewline -foregroundcolor gray
        }

        if ( $count -ge ($bufferwidth - ($len + $breather)) ) {
            write-host ""
            $count = 0
        }
    }

    write-host "" # add newline at bottom
    write-host "" # add newline at bottom
}

# Set PowerLS as the default ls Command
Set-Alias -Name ls -Value PowerLS -Option AllScope

# Paket Init
function BootstrapPaket {
	# Create a .paket folder, download the paket.bootstrapper.exe to it, verify the MD5 hash, run the bootstrapper, run paket.exe init

	$paketFolder = join-path $pwd ".paket"
	$bootstrapperFile = join-path $paketFolder "paket.bootstrapper.exe"
	$paketFile = join-path $paketFolder "paket.exe"
	$bootstrapperUrl = "https://github.com/fsprojects/Paket/releases/download/5.122.1/paket.bootstrapper.exe"
	$expectedHash = "C4239B4D7E8A0CEA0DDDD57E93076ACF"

	if (!(Test-Path "$paketFolder")) {
	    mkdir "$paketFolder" | out-null
	}

	Invoke-WebRequest -Uri $bootstrapperUrl -OutFile $bootstrapperFile

	$fileHash = Get-FileHash $bootstrapperFile -Algorithm "MD5" | select -ExpandProperty "Hash"

	if ($fileHash -ne $expectedHash) {
	    Write-Error -Message "File hash `"$fileHash`" did not match expected hash `"$expectedHash`". File may have been tampered with. Refusing to execute."
	    throw
	}

	# Run the bootstrapper and paket.exe
	& $bootstrapperFile
	& $paketFile "init"
}

Set-Alias -Name Paket-BootStrap -Value BootstrapPaket -Option AllScope

# Add an alias for the Powershell-Utils bogpaddle.ps1 script.
Set-Alias -Name bogpaddle -Value "$source\powershell-utils\bogpaddle.ps1" -Option AllScope
# Add an alias for the Powershell-Utils namegen.ps1 script.
Set-Alias -Name namegen -Value "$source\powershell-utils\namegen.ps1" -Option AllScope
# Add an alias for the Powershell-Utils kmsignalr.ps1 script.
Set-Alias -Name kmsignalr -Value "$source\powershell-utils\kmsignalr.ps1" -Option AllScope
# Add an alias for the Powershell-Utils download-video.ps1 script.
Set-Alias -Name download-video -Value "$source\powershell-utils\download-video.ps1" -Option AllScope
# Add an alias for the Powershell-Utils guid.ps1 script.
Set-Alias -Name guid -Value "$source\powershell-utils\guid.ps1" -Option AllScope
# Add an alias for the Powershell-Utils bcrypt.ps1 script.
Set-Alias -Name bcrypt -Value "$source\powershell-utils\bcrypt.ps1" -Option AllScope
# Add an alias for the Powershell-Utils now.ps1 script.
Set-Alias -Name now -Value "$source\powershell-utils\now.ps1" -Option AllScope
# Add an alias for the Powershell-Utils template.ps1 script.
Set-Alias -Name template -Value "$source\powershell-utils\template.ps1" -Option AllScope
# Add an alias for the Powershell-Utils bogpaddle.ps1 script.
Set-Alias -Name bogpaddle -Value "$source/powershell-utils\bogpaddle.ps1" -Option AllScope
# Add an alias for the Powershell-Utils namegen.ps1 script.
Set-Alias -Name namegen -Value "$source/powershell-utils\namegen.ps1" -Option AllScope
# Add an alias for the Powershell-Utils kmsignalr.ps1 script.
Set-Alias -Name kmsignalr -Value "$source/powershell-utils\kmsignalr.ps1" -Option AllScope
# Add an alias for the Powershell-Utils download-video.ps1 script.
Set-Alias -Name download-video -Value "$source/powershell-utils\download-video.ps1" -Option AllScope
# Add an alias for the Powershell-Utils guid.ps1 script.
Set-Alias -Name guid -Value "$source/powershell-utils\guid.ps1" -Option AllScope
# Add an alias for the Powershell-Utils bcrypt.ps1 script.
Set-Alias -Name bcrypt -Value "$source/powershell-utils\bcrypt.ps1" -Option AllScope
# Add an alias for the Powershell-Utils now.ps1 script.
Set-Alias -Name now -Value "$source/powershell-utils\now.ps1" -Option AllScope
# Add an alias for the Powershell-Utils template.ps1 script.
Set-Alias -Name template -Value "$source/powershell-utils\template.ps1" -Option AllScope
