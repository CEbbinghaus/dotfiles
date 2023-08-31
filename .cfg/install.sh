#!/bin/sh

clear

args="$*"
stringContainns() { case "$1" in *$2* ) return 0;; *) return 1;; esac ;}
argumentsContain() { case "$args" in *$1* ) return 0;; *) return 1;; esac ;}
argumentsDoesntContain() { case "$args" in *$1* ) return 1;; *) return 0;; esac ;}

version="1.2.1"

prompt()
{
	question="$1"

	printf "$question (y/n) "
	read answer

	if [ "$answer" != "${answer#[Yy]}" ] ;then # this grammar (the #[] operator) means that the variable $answer where any Y or y in 1st position will be dropped if they exist.
		out=true
	else
		out=false
	fi

	# old_stty_cfg=$(stty -g)
	# stty raw -echo
	# answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
	# stty $old_stty_cfg
	# if [ "$answer" != "${answer#[Yy]}" ];then
	# 	out=true
	# else
	# 	out=false
	# fi
	printf "\n"
}

print_header()
{
	printf "    ______      _    __ _ _        _____          _        _ _           
    |  _  \    | |  / _(_) |      |_   _|        | |      | | |          
    | | | |___ | |_| |_ _| | ___    | | _ __  ___| |_ __ _| | | ___ _ __ 
    | | | / _ \| __|  _| | |/ _ \   | || '_ \/ __| __/ _\` | | |/ _ \ '__|
    | |/ / (_) | |_| | | | |  __/  _| || | | \__ \ || (_| | | |  __/ |   
    |___/ \___/ \__|_| |_|_|\___|  \___/_| |_|___/\__\__,_|_|_|\___|_|  @$version
                                                                         
                                                           by CEbbinghaus\n\n"
}

if argumentsContain '-h' || argumentsContain "--help"; then
	print_header
	echo "Arguments:
	-h --help      			Prints this dialogue
	-f --force     			Forces a fresh install
	--skip-install 			Skips installing git. Ensure it exists
	--skip-clone   			Skips Cloning the repo and its submodules. lets you run only scripts
	--skip-scripts 			Skips executing any Post-Install scripts
	"
	exit 0
fi

# if [ $(readlink /proc/$$/exe) = "/bin/busybox" ]; then
# 	echo "Currently Running in Busybox. Things might break."
# 	prompt "Do you want to proceed?"

# 	if [ $out = false ]; then
# 		exit 0
# 	else
# 		clear
# 	fi
# fi

determine_distro()
{
	if   [ -f /etc/debian_version ];	then os="deb"
	elif [ -f /etc/alpine-release ];	then os="alp"
	elif [ -f /etc/alpine-release ];	then os="alp"
	elif [ -f /etc/centos-release ];	then os="cnt"
	elif [ -f /etc/fedora-release ];	then os="fed"
	elif [ -f /etc/arch-release   ];	then os="ach"
	elif [ -f /etc/redhat-release ];	then os="red"
	elif [ -f /etc/gentoo-release ];	then os="gen"
	elif [ -f /etc/SuSE-release   ];	then os="sus"
	elif [ -d /etc/nixos		  ];	then os="nix"
	fi

	echo $os
}

determine_distro_installer()
{
	os="$1"

	if   [ $os = "deb" ];	then osInstall="apt-get install -y"
	elif [ $os = "alp" ];	then osInstall="apk --update add"
	elif [ $os = "cnt" ];	then osInstall="yum install -y"
	elif [ $os = "fed" ];	then osInstall="dnf install -y"
	elif [ $os = "ach" ];	then osInstall="pacman -Su --noconfirm"
	elif [ $os = "red" ];	then osInstall="yum install"
	elif [ $os = "gen" ];	then osInstall="emerge"
	elif [ $os = "sus" ];	then osInstall="zypper install"
	fi

	echo $osInstall
}

determine_distro_name()
{
	os="$1"

	if   [ $os = "deb" ];	then osName="Debian"
	elif [ $os = "alp" ];	then osName="Alpine"
	elif [ $os = "cnt" ];	then osName="CentOS"
	elif [ $os = "fed" ];	then osName="Fedora"
	elif [ $os = "ach" ];	then osName="Arch"
	elif [ $os = "red" ];	then osName="RedHat"
	elif [ $os = "gen" ];	then osName="Gentoo"
	elif [ $os = "sus" ];	then osName="Suse"
	elif [ $os = "nix" ];	then osName="NixOS"
	fi

	echo $osName
}

# Installer script

print_header

os=$(determine_distro)

if [ -z "$os" ]
then
	echo "Couldn't Identify Host Distribution. "
	exit 1
else
	echo "Identified Distro as $(determine_distro_name "$os")\n"
fi

packages='git'

install_packages()
{
	if [ "$os" = "nix" ]; then
		echo "NixOS doesn't support installing packages..."

		missingPackages=""
		for pkg in $packages; do
			if ! command -v $pkg > /dev/null 2>&1;	then
				missingPackages="$missingPackages\n$pkg"
			fi
		done

		if [ ! -z "$missingPackges" ]; then
			printf "Some Required packages are missing. Please ensure they are installed and try again.
					\rMissing Packages:$missingPackages\n"
			exit 1
		fi

		echo "All required packages already exist. Skipping..."

		return
	fi

	printf "> Installing Packages.\n"

	install=$(determine_distro_installer "$os")

    installSuccess=0

	for pkg in $packages; do
		if ! command -v $pkg > /dev/null 2>&1; then
			printf "Installing $pkg..."
			$install "$pkg" > /dev/null 2>&1
			
			if [ $? -ne 0 ]; then
			    printf "ERR. Please Install it Manually"
			    installSuccess=1
			else
			    printf "OK"
			fi

			printf "\n"
		fi
	done

    if [ $installSuccess -eq 1 ]; then
        echo "One or more packages Failed to install. Install them manually before trying again"
        exit 1
    fi
}

if argumentsDoesntContain "--skip-install"; then
	install_packages
fi

noSubmodules=1

if argumentsDoesntContain "--skip-clone"; then

	if argumentsDoesntContain "-f"  && argumentsDoesntContain "--force" && [ -d "$HOME/.cfg" ]; then
		printf "> Dotfiles already cloned\n"
		exit 1
	fi

	printf "> Cloning dotfiles...\n"

	if [ -d "$HOME/.backup" ]; then
		echo "Backup directory already exists. Back it up or delete it before running script again"
		exit 1
	else
		echo "Creating Backup Directory"
		mkdir -p "$HOME/.backup"
	fi

	git clone --recurse-submodules --bare https://github.com/CEbbinghaus/dotfiles $HOME/.cfg > /tmp/dotinstaller.git_clone.log 2>&1

	if [ $? -ne 0 ]; then
		echo "Cloning Failed, Exiting Setup. Check your Internet Connection and try again."
		exit 1
	else
		echo "Cloned Bare Repository into .cfg"
	fi

	if [ -d "$HOME/.ssh" ]; then
		echo ".ssh Directory Already Exists. Backing it up"
		mv $HOME/.ssh $HOME/.backup/.ssh
	fi

	output=$(git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout 2>&1) # &> /dev/null

	if [ $? -eq 0 ]; then
		echo "Checked out config.";
	else
		echo "Checkout Failed. Trying to automatically back up existing dotfiles.."
		
		mkdir -p "$HOME/.config-backup"
		echo "Backing up pre-existing dot files..";
		
		if [ -d "$HOME/.ssh-backup" ]; then
			mv $HOME/.ssh-backup $HOME/.config-backup/.ssh
		fi
		
		elements="$(echo "$output" | egrep "\s+(README)?\." | awk {'print $1'})"

		for el in $elements
		do
			echo "	Backing up $el"
			if stringContainns $el "/"; then
				mkdir -p "$HOME/.config-backup/${el%*/*}"
			fi
			mv "$HOME/$el" "$HOME/.config-backup/$el"
		done
		
		echo "Finished Backing up Config files"
		
		git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout > /dev/null 2>&1
		
		echo "Checked out Files from Remote"
	fi

	git --git-dir=$HOME/.cfg/ --work-tree=$HOME submodule update --remote --init --recursive > /tmp/dotinstaller.git_submodule_clone.log 2>&1

	if [ $? -eq 0 ]; then
		echo "Checked out submodules"
	else
		echo "Failed to initialize Submodules. Please run 'config submodule update --remote --init --recursive' manually"
		noSubmodules=0
	fi


	git --git-dir=$HOME/.cfg/ --work-tree=$HOME config --local status.showUntrackedFiles no

fi

if argumentsDoesntContain "--skip-scripts"; then
	printf "> Running Postinstall Scripts\n"

	if [ $noSubmodules -eq 0 ]; then
		echo "Cannot run some scripts due to missing submodules."
	else
		echo "Running SSH Setup Script"
		output="$(sh $HOME/.ssh/setup.sh 2>&1)"
		if [ $? -eq 0 ]; then
			echo "Finished SSH Setup"
		else
			echo "There was a problem running SSH script. See output below:"
			echo "$output"
		fi
		
	fi
fi

printf "\nFinished Setting up dotfiles. run '. .bashrc' to initialize shell\n"