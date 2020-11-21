PS1="\[$(tput setaf 5)\]\A\[$(tput sgr0)\] \w$([ -n "$NNNLVL" ] && echo " nnn:$NNNLVL") \[$(tput setaf 6)\]➤ \[$(tput sgr0)\] "


# Based on https://github.com/mrzool/bash-sensible
# ------------------------------------------------
if [[ $- == *i* ]]; then
	shopt -s checkwinsize
	PROMPT_DIRTRIM=3
	bind Space:magic-space
	shopt -s globstar 2> /dev/null
	shopt -s nocaseglob
	bind "set blink-matching-paren on"
	bind "set colored-completion-prefix on"
	bind "set colored-stats on"
	bind "set completion-ignore-case on"
	bind "set completion-map-case on"
	bind "set editing-mode vi"
	bind "set keymap vi"
	bind "set mark-symlinked-directories on"
	bind "set show-all-if-ambiguous on"
	bind "set show-mode-in-prompt on"
	bind "set visible-stats on"
	bind "set vi-cmd-mode-string $(tput setaf 4)cmd $(tput sgr0)"
	bind "set vi-ins-mode-string"
	shopt -s histappend
	shopt -s cmdhist
	PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"
	bind '"\e[A": history-search-backward'
	bind '"\e[B": history-search-forward'
	bind '"\C-p": history-search-backward'
	bind '"\C-n": history-search-forward'
	bind '"\e[C": forward-char'
	bind '"\e[D": backward-char'
	shopt -s autocd 2> /dev/null
	shopt -s direxpand 2> /dev/null
	shopt -s dirspell 2> /dev/null
	shopt -s cdspell 2> /dev/null
	CDPATH="."
	shopt -s cdable_vars
fi

export CLICOLOR=1
export EDITOR="nvim"
export GOBIN="$HOME/.local/bin/go"
export GOCACHE="$HOME/.cache/go/build"
export GOMODCACHE="$HOME/.cache/go/mod"
export GOPATH="$HOME/.cache/go/lib"
export IPFS_PATH="$HOME/.cache/ipfs"
export JUNK="$HOME/Junk"
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth:ereasedups
export HISTIGNORE="?:??:???:????:?????"
export HISTTIMEFORMAT="%F %T "
export LESSCHARSET=UTF-8
export MOUNT="$HOME/Mount"
export PROJECTS="$HOME/Projects"
export SYNC="$HOME/Sync"
[[ ! "$PATH" =~ /usr/local/sbin ]] && export PATH="$PATH:/usr/local/sbin"
[[ ! "$PATH" =~ /usr/local/opt/node@12/bin ]] && export PATH="$PATH:/usr/local/opt/node@12/bin"
[[ ! "$PATH" =~ $HOME/.local/bin ]] && export PATH="$PATH:$HOME/.local/bin"
[[ ! "$PATH" =~ $HOME/Library/Python/3.8/bin ]] && export PATH="$PATH:$HOME/Library/Python/3.8/bin"
[[ ! "$PATH" =~ $GOBIN ]] && export PATH="$PATH:$GOBIN"

alias beep="tput bel"
alias less="bat"
alias l="exa -1"
alias la="exa -1a"
alias lar="exa -1aR"
alias lh="exa -1ad .??*"
alias ll="exa -lh"
alias lla="exa -ahl"
alias llar="exa -ahlR"
alias llh="exa -adhl .??*"
alias llr="exa -lhR"
alias lr="exa -1R"
alias ls="exa"
alias lsa="exa -ah"
alias n="nvim"
alias nn="nvim -Zn -u NONE -i NONE"
alias q="exit"
alias tar="COPYFILE_DISABLE=1 tar"

clear-shada () {
	rm -f ~/.local/share/nvim/shada/*.shada
}

clear-clipboard () {
	pbcopy < /dev/null
}

clipit () {
	[ -f "$1" ] && pbcopy < "$1"
}

mkcd () {
	mkdir -p "$1"
	cd "$1"
}

mnt-gocrypt () {
	[ ! -d "$1"	] && echo "Usage: mnt-gocrypt <cypherdir>" && exit 1

	local mountpoint="${MOUNT}/gocrypt$(($(/usr/bin/ls -1 $MOUNT | grep '^gocrypt*' | wc -l) + 1))"
	mkdir -p "$mountpoint" || { echo "Failed to create directory for mount point: '$mountpoint'" && exit 1; }

	# gocryptfs -allow_other "$1" "$mountpoint" && echo "Disk mounted at $mountpoint" ||
	gocryptfs "$1" "$mountpoint" && echo "Disk mounted at $mountpoint" ||
	{ echo "Failed to mount '$1'." && rmdir "$mountpoint" && exit 1; }
}

mnt-vcrypt () {
	[ ! -f "$1" ] && echo "Usage: mnt-vcrypt <veracrypt-file>" && exit 1

	local mountpoint="${MOUNT}/vcrypt$(($(/usr/bin/ls -1 $MOUNT | grep '^vcrypt*' | wc -l) + 1))"
	mkdir -p "$mountpoint" || { echo "Failed to create directory for mount point: '$mountpoint'" && exit 1; }

	veracrypt --text --keyfiles="" --pim=0 --protect-hidden=no "$1" "$mountpoint" &&
	echo "Disk mounted at $mountpoint" ||
	{ echo "Failed to mount '$1'." && rmdir "$mountpoint" && exit 1; }
}

qemu-create () {
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "qemu-create <volume-name> <volume-size><G|M|K>"
		echo "example: qemu-create vm1 16G"
		exit 0;
	fi

	[ -z "$1" ] && echo "ERROR: missing volume name." && exit 1
	[ -z "$2" ] && echo "ERROR: missing volume size." && exit 1

	qemu-img create -f qcow2 "$1".img.qcow2 "$2"
}

qemu-snapshot () {
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "qemu-snapshot <source-volume> <snapshot-volume-name>"
		echo "example: qemu-snapshot vm1 vm1-snapshot"
		exit 0;
	fi

	[ ! -f "$1" ] && echo "ERROR: missing or invalid source volume." && exit 1
	[ ! -z "$2" ] && echo "ERROR: missing snapshot volume name." && exit 1

	qemu-img create -f qcow2 -b "$(pwd)/$2" "$(pwd)/$3";
}

qemu-start () {
	local cdrom=""
	local mem="2G"
	local smp="2"
	local ssh="10022"
	local volume=""
	while [[ $# -gt 0 ]]
	do
		case "$1" in
			-h|--help)
				echo "qemu-start -v|--volume <volume> [-c|--cdrom <iso>] " \
					"[-m|--mem <ram-size><G|M|K> (default $mem)] " \
					"[-s|--smp <num-cpus> (defaul $smp)] [--ssh <ssh-fwd-port> (default $ssh)]"
				exit 0
				;;
			-c|--cdrom)
				cdrom="$2"
				shift
				shift
				;;
			-v|--volume)
				volume="$2"
				shift
				shift
				;;
			-m|--mem)
				mem="$2"
				shift
				shift
				;;
			-s|--smp)
				smp="$2"
				shift
				shift
				;;
			--ssh)
				ssh="$2"
				shift
				shift
				;;
			*)
				printwarn "Unknown option: '$1'. Will be ignored."
				shift
				;;
		esac
	done

	[ ! -f "$volume" ] && echo "ERROR: missing or invalid volume." && exit 1
	[ -n "$cdrom" ] && [ ! -f "$cdrom" ] &&  echo "ERROR: invalid cdrom file." && exit 1

	qemu-system-x86_64 -enable-kvm -machine q35 -device intel-iommu \
		-object rng-random,filename=/dev/random,id=rng0 -device virtio-rng-pci,id=rng0 \
		-cpu max -smp "$smp" -m "$mem" -vga virtio -display sdl,gl=on \
		-drive file="/usr/share/edk2-ovmf/x64/OVMF_CODE.fd",if=pflash,format=raw,readonly=on \
		-drive file="/usr/share/edk2-ovmf/x64/OVMF_VARS.fd",if=pflash,format=raw,readonly=on \
		-cdrom "$cdrom" -boot order=dc,menu=on \
		-drive file="$volume",format=qcow2,if=virtio,aio=native,cache.direct=on \
		-nic user,model=virtio-net-pci,hostfwd=tcp::"$ssh"-:22
}

secrm () {
	if [ $# -gt 0 ]; then
		shred --iterations=1 --random-source=/dev/urandom -u --zero $*
	else
		echo "Usage: secrm <files...>"
	fi
}

shup () {
	[ ! -f "$1" ] && echo "Usage: shup <cmdfile>" && exit 0

	local profile="$1"
	local cmd=""

	while read -r line; do
		line="${line##*( )}"
		[ -n "$line" ] && [ ${line:0:1} != "#" ] && cmd="${cmd} ${line}"
	done < "$profile"

	eval $cmd
}

umnt () {
	# Find the directories at $MOUNT that are already used as a mount point.
	# Taken from: https://catonmat.net/set-operations-in-unix-shell
	# local mountpoint=$(comm -12 <(/bin/ls -1Ld $MOUNT/* | sort) \
	# 	<(mount | awk '{print $3}' | sort) | fzf)
	# [ -z $mountpoint ] && return

  for dir in $(/bin/ls -1Ld $MOUNT/* 2> /dev/null); do
		local source="$(findmnt --first-only --noheadings --output SOURCE $dir)"
		if [ "$source" ]; then
			local mounts="${mounts}\n$(findmnt --first-only --noheadings --output SOURCE $dir |
				awk -v dir="$dir" '{print dir " -> " $1}')"
		fi
	done

	[ "$mounts" ] &&
	local mountpoint=$(printf "$mounts" | tail -n +2 | fzf | awk '{print $1}') ||
	{ echo "No mounted volumes at $MOUNT/" && exit 1; }

	if [[ "$mountpoint" =~ vcrypt ]]; then
		veracrypt --text --dismount "$mountpoint" && echo "Unmounted '$mountpoint'."
		rmdir "$mountpoint"
	elif [ "$mountpoint" ]; then
		sudo umount "$mountpoint" && echo "Unmounted '$mountpoint'."
		rmdir "$mountpoint"
	fi
}

vcrypt-create () {
	[ -z "S1" ] || [ -z "$2" ] && \
		echo "Usage: vcrypt-create <path-to-encrypted-file> <size><K|M|G>" && \
		exit 1;

	veracrypt --text --create "$1" --volume-type="normal" --size="$2" --filesystem="exFAT" \
		--encryption="AES" --hash="SHA-512" --pim=0 --keyfiles="" --random-source="/dev/random"
}

[ -r "/usr/local/etc/profile.d/bash_completion.sh" ] && . "/usr/local/etc/profile.d/bash_completion.sh"

export FZF_DEFAULT_COMMAND="fd --exclude '.git/' --hidden --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --exclude '.git/' --hidden --type d"
[[ $- == *i* ]] && . "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null
[ -f "/usr/local/opt/fzf/shell/key-bindings.bash" ] && . "/usr/local/opt/fzf/shell/key-bindings.bash"

# encgpg: Encrypt stdin with password into a given file
# decgpg: Decrypt given file into a nvim buffer
export GPG_TTY=$(tty)
function encgpg { gpg -c -o "$1"; }
function decgpg { gpg -d "$1" | nvim -i NONE -n -; }

export NNN_BMS='d:~/Downloads;j:~/Junk;p:~/Projects;s:~/Sync;v:/Volumes'
export NNN_PLUG='a:archive;d:fzcd;e:_nvim $nnn*;f:-fzopen;k:-pskill'
e () {
	nnn -x "$@"
	export NNN_TMPFILE="$XDG_CONFIG_HOME/nnn/.lastd"

	if [ -f "$NNN_TMPFILE" ]; then
		. "$NNN_TMPFILE"
		rm -f "$NNN_TMPFILE" &> /dev/null
	fi
}
