
# Check if the script is running with Elevated privileges and relaunch it as admin if not
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

# Helper Function Definitions
function IsSystemLink([string]$path) {
  $file = Get-Item $path -Force -ea SilentlyContinue
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

# check if wsl is even installed
try{
	(wsl -l) | Out-Null
}catch{
	echo "Windows Subsystem for Linux is Not installed. "
	Break
}

if($args.count -gt 0){

	$wslHome = $args[0]
	
} else {
	
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

$links = (
	(("$wslHome\.ssh"), ("$HOME"), ('.ssh'), ($true)),
	(("$wslHome\.wt"), ("$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe"), ('LocalState'), ($true)),
	(("$wslHome\.gitconfig"), ("$HOME"), ('.gitconfig'), ($false))
)

$backup = "$HOME\dotbackup\"

if(Test-Path $backup){
	if (Test-Path "$backup\*"){
		echo "A Backup already Exists. Discard the Backup before trying again"
		Break
	}
}else{
	mkdir $backup
}

foreach($link in $links){
	$source = $link[0]
	$directory = $link[1]
	$target = $link[2]
	$isDirectory = $link[3]

	$linkpath = "$directory\$target"

	if(Test-Path $linkpath){
		if(IsSystemLink($linkpath)){
			echo "$target Already looks to be linked. Skipping it"
			continue
		}
		echo "$target Already exists. Backing it up"
		mv $linkpath $backup
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