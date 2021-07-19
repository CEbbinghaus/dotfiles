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

	if ! command -v git &> /dev/null
	then
		${install} "git"
	fi

fi

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

/usr/bin/git clone --bare https://github.com/CEbbinghaus/dotfiles $HOME/.cfg 

if [ $? -ne 0 ]; then
	echo "Cloning Failed, Exiting Setup. Check your Internet Connection and try again."
	exit 1
fi

mkdir -p .config-backup && \

config checkout

if [[ $? == 0 ]]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;

config checkout

config config --local status.showUntrackedFiles no

