# Script level Paramters
param (
	[switch] $Wsl = $false,
	[string] $HomePath = "$HOME",
	[switch] $Force = $false
)

# Check if the script is running with Elevated privileges and relaunch it as admin if not
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	$PSHost = If ($PSVersionTable.PSVersion.Major -le 5) { 'PowerShell' } Else { 'PwSh' }
	Start-Process -Verb RunAs $PSHost (@(' -NoExit')[!$NoExit] + " -File `"$PSCommandPath`" " + ($MyInvocation.Line -split '\.ps1[\s\''\"]\s*', 2)[-1])
	Break
}

function IsSystemLink([string]$path) {
    $file = Get-Item $path -Force -ea SilentlyContinue
    return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

if($Wsl){
	# Exit Early if WSL is not installed
	try{
		(wsl -l) | Out-Null
	}catch{
		Write-Error "Windows Subsystem for Linux is Not installed. "
		Break
	}
	
	
	# Grab either the Path from the argument or assume the default
	if (-not $HomePath) {
	
		Write-Output "Reading Default WSL Values"
		
		# Just as a Backup to make sure all Encoding is the same
		$PSDefaultParameterValues['*:Encoding'] = 'utf8'
		
		# Has to exist before the Encoding is set. because Reasons 🤷‍♂️
		$wslUser = (wsl "whoami")
		
		Write-Output "Linux User: $wslUser"
		
		# Nessecary for the output of wsl -l to work. 
		# Something wrong with the Encoding. More info can be found here:
		# https://stackoverflow.com/questions/64104790/powershell-strange-wsl-output-string-encoding
		# [System.Console]::OutputEncoding = [System.Text.Encoding]::Unicode
		# [System.Console]::InputEncoding = [System.Text.Encoding]::Unicode
		
		if ($((wsl -l) -replace '\x00', '' -join ' ') -match '(?sm)(?:\n|\s|)(\w+)\s\(Default\)') {
			$wslDistro = $Matches[1]
		} else {
			Write-Error "Could not Identify Default Distro"
			exit 1
		}
		
		Write-Output "Linux Distro: $wslDistro"
		
		$wslRoot = "\\wsl`$\$wslDistro"
		
		$HomePath = ("$wslRoot\home\$wslUser")
	}
}
	
Write-Output "Home set as: $HomePath"

# Variables. 
$links = (
	(".wt", "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe", 'LocalState', $true),
	(".pwsh", "$HOME\Documents", 'PowerShell', $true),
	(".pwsh", "$HOME\Documents", 'WindowsPowerShell', $true),
	(".ssh", "$HOME", '.ssh', $true),
  	(".gitconfig", "$HOME", '.gitconfig', $false)
)

$BackupPath = "$HOME\Backup\__LINKBACKUP__"

if (!$Force){
	if (Test-Path $BackupPath) {
		if (Test-Path "$BackupPath\*"){
			Write-Output "A Backup already Exists. Discard the Backup before trying again"
			Write-Output "Press any key to Exit..."
			$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			Break
		}
	}else{
		New-Item $BackupPath -ItemType Directory *> $null
		mkdir $BackupPath *> $null
	}
}

foreach($link in $links){
	$source = "$HomePath\$($link[0])"
	$directory = $link[1]
	$target = $link[2]
	$isDirectory = $link[3]

	$linkpath = "$directory\$target"

	if($source -eq $linkpath)
	{
		Write-Output "Skipping $target"
		continue
	}

	if (Test-Path $linkpath) {
		if ($Force) {
			(Get-Item $linkpath).Delete()
		}else{
			if(IsSystemLink($linkpath)){
				Write-Output "$target Already looks to be linked. Skipping it"
				continue
			}
			Write-Output "$target Already exists. Backing it up"
			Move-Item $linkpath $BackupPath
		}
	}else{
		if(-not (Test-Path $directory)) {
			mkdir $directory *> $null
		}
	}
	
	Write-Output "Linking: $target"

	$dirarg = ""
	if($isDirectory){
		$dirarg = "/D"
	}

	cmd /C "cd $directory & mklink $dirarg $target $source" *> $null

	if(-not $?) {
		Write-Error "Unable to link $target"
	}
}
if($Wsl)
{
	Write-Output "Press any key to Exit..."
	$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") *> $null
}