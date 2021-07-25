# Script level Paramters
param (
     [string] $WslHomePath = $null,
     [switch] $Force = $false
)

# Check if the script is running with Elevated privileges and relaunch it as admin if not
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	$PSHost = If ($PSVersionTable.PSVersion.Major -le 5) { 'PowerShell' } Else { 'PwSh' }
	Start-Process -Verb RunAs $PSHost (@(' -NoExit')[!$NoExit] + " -File `"$PSCommandPath`" " + ($MyInvocation.Line -split '\.ps1[\s\''\"]\s*', 2)[-1])
	Break
}

# Helper Function Definitions
function IsSystemLink([string]$path) {
  $file = Get-Item $path -Force -ea SilentlyContinue
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}


# Exit Early if WSL is not installed
try{
	(wsl -l) | Out-Null
}catch{
	echo "Windows Subsystem for Linux is Not installed. "
	Break
}


# Grab either the Path from the argument or assume the default
if ($WslHomePath) {

	$wslHome = $WslHomePath
	
} else {
	
	echo "Reading Default WSL Values"

	# Just as a Backup to make sure all Encoding is the same
	$PSDefaultParameterValues['*:Encoding'] = 'utf8'
	
	# Has to exist before the Encoding is set. because Reasons 🤷‍♂️
	$wslUser = (wsl "whoami")
	
	echo "Linux User: $wslUser"
	
	# Nessecary for the output of wsl -l to work. 
	# Something wrong with the Encoding. More info can be found here:
	# https://stackoverflow.com/questions/64104790/powershell-strange-wsl-output-string-encoding
	# [System.Console]::OutputEncoding = [System.Text.Encoding]::Unicode
	# [System.Console]::InputEncoding = [System.Text.Encoding]::Unicode
	
	if ($((wsl -l) -replace '\x00', '' -join ' ') -match '(?sm)(?:\n|\s|)(\w+)\s\(Default\)') {
		$wslDistro = $Matches[1]
	} else {
		echo "Could not Identify Default Distro"
		Break
	}

	echo "Linux Distro: $wslDistro"

	$wslRoot = "\\wsl`$\$wslDistro"

	$wslHome = ("$wslRoot\home\$wslUser")
}

echo "Home set as: $wslHome"

# Variables. 
$links = (
	(("$wslHome\.ssh"), ("$HOME"), ('.ssh'), ($true)),
	(("$wslHome\.wt"), ("$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe"), ('LocalState'), ($true)),
	(("$wslHome\.gitconfig"), ("$HOME"), ('.gitconfig'), ($false))
)


$backup = "$HOME\dotbackup\"

if (!$Force){
	if (Test-Path $backup) {
		if (Test-Path "$backup\*"){
			echo "A Backup already Exists. Discard the Backup before trying again"
			$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			Break
		}
	}else{
		mkdir $backup
	}
}

foreach($link in $links){
	$source = $link[0]
	$directory = $link[1]
	$target = $link[2]
	$isDirectory = $link[3]

	$linkpath = "$directory\$target"

	if ((Test-Path $linkpath)) {
		if ($Force) {
			(Get-Item $linkpath).Delete()
		}else{
			if(IsSystemLink($linkpath)){
				echo "$target Already looks to be linked. Skipping it"
				continue
			}
			echo "$target Already exists. Backing it up"
			mv $linkpath $backup
		}
	}
	
	echo "Linking: $linkpath"

	$dirarg = ""
	if($isDirectory){
		$dirarg = "/D"
	}

	cmd /C "cd $directory & mklink $dirarg $target $source"
}

Write-Output "Press any key to Exit..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")