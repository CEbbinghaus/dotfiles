#!/usr/local/bin/powershell

########################### DEFINITIONS AND HELP

param (
	[Alias("h")]
	[switch]$Help,
	[switch]$Force,
	[Alias("skip-install")]
	[switch]$SkipInstall, 
	[Alias("skip-clone")]
	[switch]$SkipClone, 
	[Alias("skip-scripts")]
	[switch]$SkipScripts,
	[Alias("skip-links")]
	[switch]$SkipLinks
)
$Buckets = ("nerd-fonts")
$Packages = ("sudo", "fzf", "starship", "openssh", "FiraCode-NF:global")

if ($Help) {
	Write-Output "    Chris' Dotfile Installer
	-h -help      			Prints this dialogue
	-force        			Forces the win script to overwrite links/files that already exist. No BACKUPS WILL BE MADE
	-skip-install 			Skips installing scoop and Packages. Ensure that all nessecary packages already exist it exists
	-skip-clone   			Skips Cloning the repo and its submodules. lets you run only scripts
	-skip-scripts 			Skips executing any Post Install scripts
	-skip-links 			Skips linking the folders/files to the home directory
	"
	exit 0
}


############################ ALIAS FUNCTIONS ####################################

function config()
{
    & git --git-dir=$HOME/.cfg/ --work-tree=$HOME $args
}

############################# UTILITY FUNCTIONS #################################
function RunningAsAdmin {
	$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function ExistsInPath {
	param (
		[string]$Command
	)

	if(Get-Command -ea si $Command){
		return $True;
	}
	
	return $False;
}

$BackupPath = "~/Backup"

function Backup {
	param (
		[string]$Target,
		[string]$ExitExpression
	)

	if(-not (Test-Path $Target))
	{
		return
	}


	$Name = $Target | split-path -leaf
	$BackupPath = "$BackupDir/$Name"
	
	if(Test-Path $BackupPath)
	{
		if(-not ($Force -or (Confirm "Backup of $Name already Exists. Overwrite?")))
		{
			if(Confirm "Continue Installation without Backing up $Name? It will be lost")
			{
				return
			} else {
				Write-Output "Exiting Installation..."
				if($ExitExpression){
					Invoke-Expression $ExitExpression
				}
				exit 1
			}
		}

		Remove-Item -Recurse -Force $BackupPath
	}

	Output "Backing up $Target"
	Move-Item $Target $BackupPath
}

function InvokeExternalScript {
	param (
		[string]$Script
	)

	$origpos = $host.UI.RawUI.CursorPosition
	
	&"$Script"
	$newpos = $host.UI.RawUI.CursorPosition

	$lines = $newpos.Y - $origpos.Y
	$host.UI.RawUI.CursorPosition = $origpos
	for($i = 0; $i -lt $lines; ++$i) {
		Write-Output "$(" " * $Host.UI.RawUI.WindowSize.Width)"
	}
	$host.UI.RawUI.CursorPosition = $origpos

	$host.UI.RawUI.CursorPosition = $origpos
}

function Confirm {
	param (
		[string]$Message
	)
	$origpos = $host.UI.RawUI.CursorPosition

	$reply = Read-Host -Prompt "$Message [y/n]"

	$host.UI.RawUI.CursorPosition = $origpos
	if ( $reply -match "[yY]" ) { 
		return $True
	}
	return $False
}

$IndentationCount = 0;
function Output {
	[CmdletBinding()]
	param (
		[string[]]
		[Parameter(ValueFromPipeline)]
		$Message
	)
	process {
		$Prefix = "*"
		
		if($IndentationCount -eq 0) {
			$Prefix = ">"
		}
		
		$output = "$("    " * $IndentationCount)$Prefix $Message"
		$Padding = $Host.UI.RawUI.WindowSize.Width - $output.Length
		Write-Output "$output$(" " * $Padding)"
	}
}

$BackupPath = "$HOME/Backup"

# Create Backup Directory if it does not already exist
if(-not (Test-Path $BackupPath)) {
	New-Item $BackupPath -ItemType Directory *> $null
}

################################# SCRIPT #######################################################

# Set up the execution Policy and Environment Variables
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
[Environment]::SetEnvironmentVariable('GIT_REDIRECT_STDERR', '2>&1', 'Process')

# Install All necessary Programms 
if(-not $SkipInstall) {
	Output "Installing Package Manager and Necessary Packages"
	$ScoopExists = ExistsInPath scoop
	$IndentationCount++
	
	if($ScoopExists) {
		Output "Scoop Exists. Skipping Installation"
	} else {
		Output "Installing Scoop..."
		trap {
			Write-Error "There was a Critical Error installing Scoop.`n$_`nExiting..."
			exit 1
		}

		if(-not (RunningAsAdmin))
		{	
			Invoke-RestMethod get.scoop.sh | Invoke-Expression *> $null
		} else {
			$confirmed = Confirm "Currently running as Administrator. Install Scoop as Administrator?"
			if (-not $confirmed) {
				Write-Host 'Exiting Scoop Installation.'
				exit 1
			}
			Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin" *> $null
		}
		Output "Finished Installing Scoop"
	}

	$GitExists = ExistsInPath git

	if(-not $GitExists) 
	{
		Output "Git could not be found in path. Installing it via scoop..."
		scoop install git *> $null

		if($?) {
			Output "Finished Installing Git"
		}else{
			Output "Failed to install Git. Aborting"
			exit 1
		}
	}

	if($Buckets)
	{
		Output "Adding Buckets"
		$IndentationCount++
		$ExistingBuckets = (scoop bucket list).Name
		$MissingBuckets = $Buckets | Where-Object { $_ -notin $ExistingBuckets }
		foreach($Bucket in $MissingBuckets)
		{
			Output "Adding Bucket: $Bucket..."
			scoop bucket add $Bucket *> $null
			
			if($?) {
				Output "Finished adding Bucket $Bucket"
			}else{
				Output "Failed to install Bucket $Bucket"
				exit 1
			}
		}
		$IndentationCount--
	}
	
	Output "Installing Packages"
	$IndentationCount++
	foreach($Package in $Packages)
	{	
		$PackageName, $IsGlobal = $Package -split ":"

		$PackageExists = ExistsInPath $PackageName
		
		if($PackageExists) {
			Output "Package $PackageName Is Already installed. Skipping it"
		}else{
			if($IsGlobal) {
				$(sudo scoop install $PackageName --global) *> $null
			} else {
				scoop install $PackageName *> $null
			}

			if($?) {
				Output "Installed $PackageName"
			}else{
				Output "Failed to install $PackageName"
			}
		}
	}
	$IndentationCount--

	$IndentationCount--
}

# Clone git Repository into Home Dir
if(-not $SkipClone) {
	Output "Cloning Git Repository"
	$IndentationCount++

	if (Test-Path "$HOME/.cfg")
	{
		Output "Config Already Cloned."
	} else {
		
		Output "Cloning Repository..."
		&git clone  --recurse-submodules --bare https://github.com/CEbbinghaus/dotfiles $HOME/.cfg *> $null
		
		if (-not $?)
		{
			Output "Cloning Failed, Exiting Setup. Check your Internet Connection and try again."
			exit 1
		} else {
			Output "Cloned Bare Repository into .cfg"
		}
	}

	Backup "$HOME/.ssh"

	config checkout *> $null

	if ($?)
	{
		Output "Checked out config.";
	}
	else
	{
		Output "Failed to check out Config"
		
		Output "Backing up of dot files is currently not supported"
		exit 1
		# Output "Backing up pre-existing dot files.";

		# Remove-Item -Recurse -Force $HOME/.cfg
		
		# readarray -t elements <<< "$(config checkout 2>&1 | egrep "\s+\." | awk {'print $1'})"
		
		# for el in "${elements[@]}"
		# do
		# if [[ $el == *"/"* ]]; then
		# mkdir -p "$HOME/.config-backup/${el%*/*}"
		# fi
		# mv $el "$HOME/.config-backup/$el"
		# done
		
		# echo "Finished Backing up Config files"
		
		# config checkout *> $null
		
		# echo "Checked out Files from Remote"
	}

	config reset --hard *> $null

	if(-not $?) {
		Output "Failed to Reset repository"
	}

	config submodule update --remote --init --recursive *> $null

	if($?){
		Output "Checked out submodules"
	} else {
		Output "Failed to check out Submodules"
	}

	$IndentationCount--
	
	config config --local status.showUntrackedFiles no *> $null
}

# Run Scripts to set up various different bits
if(-not $SkipScripts){
	Output "Running Scripts"
	$IndentationCount++
	if(Test-Path $HOME/.ssh/config) {
		Output "Running SSH Setup Script"
		&"$HOME\.ssh\setup.ps1" | Output
		Output "Finished SSH Setup"
	} else {
		Output "Unable to run SSH scripts"
	}
	
	$IndentationCount--
}

# Link Files to home directory

if(-not $SkipLinks) {
	Output "Linking Files with Symbolic Links"
	$IndentationCount++
	&"$HOME\.cfg\linkdir.ps1"
	Output "Finished Linking Files"
	$IndentationCount--
}


# if [[ "$*" != *"--skip-scripts"* && "$*" != *"--skip-win-scripts"* ]]; then
# 	if command -v wslpath -w $HOME &> /dev/null
# 	then
# 		echo "Windows Subsystem for Linux Detected. Running windows setup script"
# 		wslhome=$(wslpath -w $HOME)
# 		force=""

# 		if ["$*" != *"--force-win-script"*]; then
# 			force="-Force"
# 		fi

# 		powershell.exe "$wslhome\.cfg\winsetup.ps1 -WslHomePath $wslhome $force"
# 	fi
# fi

# echo "Finished Setting up dotfile Environment."
