#!/bin/bash
shopt -s expand_aliases

if [[ "$*" == *'-h'* || "$*" == *"--help"* ]]; then
	echo " Chris' Dotfile Installer
	-h --help      			Prints this dialogue
	--skip-install 			Skips installing git. Ensure it exists
	--skip-clone   			Skips Cloning the repo and its submodules. lets you run only scripts
	--skip-scripts 			Skips executing any Post Install scripts
	--skip-bash-scripts		Skips only bash scripts
	--skip-win-scripts 		Skips only Windows (wsl) Install scripts
	--force-win-script		Forces the win script to overwrite links/files that already exist. No BACKUPS WILL BE MADE
	"
	exit 0
fi

if [[ "$*" != *"--skip-install"* ]]; then

	declare -A osInfo
	osInfo[/etc/debian_version]="deb"
	osInfo[/etc/alpine-release]="alp"
	osInfo[/etc/centos-release]="cnt"
	osInfo[/etc/fedora-release]="fed"
	osInfo[/etc/arch-release]="ach"

	declare -A osInstall;
	osInstall["deb"]="apt-get install -y"
	osInstall["alp"]="apk --update add"
	osInstall["cnt"]="yum install -y"
	osInstall["fed"]="dnf install -y"
	osInstall["ach"]="pacman -Su --noconfirm"

	declare -A osName;
	osName["deb"]="Debian"
	osName["alp"]="Alpine"
	osName["cnt"]="CentOS"
	osName["fed"]="Fedora"
	osName["ach"]="Arch"

	for f in ${!osInfo[@]}
	do
		if [[ -f $f ]];then
			os=${osInfo[$f]}
		fi
	done

	if [ -z "$os" ]
	then
		echo "Couldn't Identify Host Distribution. "
		exit 1
	else
		echo "Identified Distro as ${osName["$os"]}"
	fi

	install=${osInstall["$os"]}

	declare -a packages
	packages=(git gpg zsh)

    installSuccess=true

	for pkg in ${packages[@]}; do

		echo "Checking for Existing $pkg installation"
		if ! command -v $pkg --{00000000-0000-0000-0000-000000000000} &> /dev/null
		then
			echo "Installing $pkg"
			${install} "$pkg" > /dev/null
			
			if [ $? -ne 0 ]; then
			    echo "Failed to Install $pkg. Please Install it Manually"
			    installSuccess=false
			else
			    echo "Finished Installing $pkg"
			fi
		fi
	done

    if [[ $installSuccess == false ]]; then
        echo "One or more packages Failed to install. Install them manually before trying again"
        exit 1
    fi

fi

if [[ "$*" != *"--skip-clone"* ]]; then

	alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

	if [ -d "$HOME/.cfg" ]; then
		echo "Config Already Cloned."
		exit 1
	fi

	/usr/bin/git clone --bare https://github.com/CEbbinghaus/dotfiles $HOME/.cfg &> /dev/null

	if [ $? -ne 0 ]; then
		echo "Cloning Failed, Exiting Setup. Check your Internet Connection and try again."
		exit 1
	else
		echo "Cloned Bare Repository into .cfg"
	fi

	if [[ -d "$HOME/.ssh" ]]; then
		echo ".ssh Directory Already Exists. Backing it up"
		mv $HOME/.ssh $HOME/.sshbackup
	fi

	config checkout &> /dev/null

	if [[ $? == 0 ]]; then
		echo "Checked out config.";
	else
		if [ -d "$HOME/.config-backup" ]; then
			echo "Backup Already Exists. Back it up or delete it before running script again"
			rm -rf $HOME/.cfg
			exit 1
		fi
		
		mkdir -p "$HOME/.config-backup" && \
		echo "Backing up pre-existing dot files.";
		
		if [[ -d "$HOME/.sshbackup" ]]; then
			mv $HOME/.sshbackup $HOME/.config-backup/.ssh
		fi
		
		readarray -t elements <<< "$(config checkout 2>&1 | egrep "\s+\." | awk {'print $1'})"

		for el in "${elements[@]}"
		do
			if [[ $el == *"/"* ]]; then
				mkdir -p "$HOME/.config-backup/${el%*/*}"
			fi
			mv $el "$HOME/.config-backup/$el"
		done
		
		echo "Finished Backing up Config files"
		
		config checkout &> /dev/null
		
		echo "Checked out Files from Remote"
	fi;

	config submodule update --remote --init --recursive &> /dev/null

	echo "Checked out submodules"

fi

if [[ "$*" != *"--skip-scripts"* && "$*" != *"--skip-bash-scripts"* ]]; then

	echo "Running SSH Setup Script"
	$HOME/.ssh/setup.sh
	echo "Finished SSH Setup"

	config config --local status.showUntrackedFiles no

fi

if [[ "$*" != *"--skip-scripts"* && "$*" != *"--skip-win-scripts"* ]]; then
	if command -v wslpath -w $HOME &> /dev/null
	then
		echo "Windows Subsystem for Linux Detected. Running windows setup script"
		wslhome=$(wslpath -w $HOME)
		force=""

		if ["$*" != *"--force-win-script"*]; then
			force="-Force"
		fi

		powershell.exe "$wslhome\.cfg\winsetup.ps1 -WslHomePath $wslhome $force"
	fi
fi

echo "Finished Setting up dotfile Environment."