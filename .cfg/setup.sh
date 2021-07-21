#!/bin/bash
shopt -s expand_aliases

if [[ $1 == "-h" || $1 == "--help" ]]; then
	echo " Chris' Dotfile Installer
	-h --help Prints this dialogue
	--skip-install Skips installing git. Ensure it exists
	"
	exit 0
fi

if [[ $1 != "--skip-install" ]]; then

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
	
	echo "Checking for Existing Git installation"
	if ! command -v git &> /dev/null
	then
		echo "Installing Git"
		${install} "git" > /dev/null
		echo "Finished Installing Git"
	fi

fi

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

config checkout &> /dev/null

if [[ $? == 0 ]]; then
	echo "Checked out config.";
else
    if [ -d "$HOME/.config-backup" ]; then
		echo "Backup Already Exists. Back it up or delete it before running script again"
		exit 1
    fi
	
	mkdir -p "$HOME/.config-backup" && \
    echo "Backing up pre-existing dot files.";
    readarray -t elements <<< "$(config checkout 2>&1 | egrep "\s+\." | awk {'print $1'})"

    for el in "${elements[@]}"
    do
        if [[ $el == *"/"* ]]; then
            mkdir -p "$HOME/.config-backup/${el%*/*}"
        fi
        mv $el "$HOME/.config-backup/$el"
    done
    echo "Finished Backing up Config files"
	
	config checkout
	
	echo "Checked out Files from Remote"
fi;

config submodule init > /dev/null
config submodule update --recursive > /dev/null

echo "Checked out submodules"

config config --local status.showUntrackedFiles no

echo "Finished Setting up dotfile Environment. Swap to zsh, Copy Windows Files into their respective locations and enjoy"
