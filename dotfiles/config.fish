set fish_greeting

set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_hide_untrackedfiles 1
set -g __fish_git_prompt_showupstream "informative"
set -g __fish_git_prompt_char_upstream_ahead "↑"
set -g __fish_git_prompt_char_upstream_behind "↓"
set -g __fish_git_prompt_char_upstream_prefix ""
set -g __fish_git_prompt_char_cleanstate "#"
set -g __fish_git_prompt_char_conflictedstate "!"
set -g __fish_git_prompt_char_dirtystate "~"
set -g __fish_git_prompt_char_stagedstate "+"
set -g __fish_git_prompt_char_untrackedfiles "?"
set -g __fish_git_prompt_color_branch magenta
set -g __fish_git_prompt_color_dirtystate blue
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
set -g __fish_git_prompt_color_cleanstate green
set -g fish_color_command blue --bold
set -g fish_color_cwd black --background green
set -g fish_color_nnn black --background blue
set -g fish_color_error brred --bold

set -U ENABLE_GIT_PROMPT 1
function fish_prompt
	if test "$ENABLE_GIT_PROMPT" = 1
		printf '%s %s %s%s%s%s%s ➤ ' (set_color $fish_color_cwd) (prompt_pwd) \
			(set_color $fish_color_nnn) ([ -n "$NNNLVL" ] && echo " $NNNLVL ") (set_color $fish_color_normal) \
			(set_color $fish_color_normal) (__fish_git_prompt || echo ' ')
	else
		printf '%s %s %s%s%s ➤ ' (set_color $fish_color_cwd) (prompt_pwd) \
			(set_color $fish_color_nnn) ([ -n "$NNNLVL" ] && echo " $NNNLVL ") (set_color $fish_color_normal)
	end
end

function fish_right_prompt
	printf '%s%s%s' (date '+%T')
end

function enable_git_prompt
	set -U ENABLE_GIT_PROMPT 1
end
function disable_git_prompt
	set -e -U ENABLE_GIT_PROMPT
end

function fish_mode_prompt
  switch $fish_bind_mode
    case default
      set_color --background red
      set_color black
      echo ' C '
			set_color normal
			#echo ' '
    case insert
      echo ''
    case replace_one
      set_color --background green
      set_color black
      echo ' R '
			set_color normal
			#echo ' '
    case visual
      set_color --background yellow
      set_color black
      echo ' S '
			set_color normal
			#echo ' '
    case '*'
      set_color --background blue
      set_color black
      echo ' ? '
			set_color normal
			#echo ' '
  end
end

fish_vi_key_bindings

set --export EDITOR nvim
set --export LESSCHARSET UTF-8
set --export GOBIN "$HOME/.local/bin/go"
set --export GOCACHE "$HOME/.cache/go/build"
set --export GOMODCACHE "$HOME/.cache/go/mod"
set --export GOPATH "$HOME/.cache/go/lib"
set --export IPFS_PATH "$HOME/.cache/ipfs"
set --export JUNK "$HOME/Junk"
set --export MOUNT "$HOME/Mount"
set --export PROJECTS "$HOME/Projects"
set --export SYNC "$HOME/Sync"
set --append PATH /usr/local/sbin
set --append PATH /usr/local/opt/fzf/bin
set --append PATH /usr/local/opt/node@12/bin
set --append PATH "$HOME/.local/bin"
set --append PATH "$HOME/Library/Python/3.8/bin"
set --append PATH "$GOBIN"

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
alias tar="env COPYFILE_DISABLE=1 tar"


function clear-shada --description "Clear neovim persistent history"
	rm -f ~/.local/share/nvim/shada/*.shada
end

function clear-clipboard --description "Clear the clipboard"
	pbcopy < /dev/null
end

function clipit --description "Copy the content of a file to the clipboard"
	[ -f "$argv[1]" ] && pbcopy < "$argv[1]"
end

function qemu-create --description "Create QEMU qcow2 disk"
	bash -l -c "qemu-create $argv"
end

function qemu-snapshot --description "Create a snapshot of QEMU disk"
	bash -l -c "qemu-snapshot $argv"
end

function qemu-start --description "Starts a QEMU VM"
	bash -l -c "qemu-start $argv"
end

function mkcd --description "Make directory and cd into it"
	mkdir "$argv[1]"
	cd "$argv[1]"
end

function mnt-gocrypt --description "Mount a folder encrypted by gocryptfs"
	bash -l -c "mnt-gocrypt $argv"
end

function mnt-vcrypt --description "Mount a Veracrypt file"
	bash -l -c "mnt-vcrypt $argv"
end

function secrm --description "Delete files securely"
	bash -l -c "secrm $argv"
end

function shup --description "Evaluate Bash commands out of a file"
	bash -l -c "shup $argv"
end

function umnt --description "Unmount a partition, gofscrypt folder or Veracrypt file"
	bash -l -c "umnt $argv"
end

function vcrypt-create --description "Create a password-encrypt Veracrypt file"
	bash -l -c "vcrypt-create $argv"
end


set --export FZF_DEFAULT_COMMAND "fd --exclude '.git/'  --hidden --type f"
set --export FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set --export FZF_ALT_C_COMMAND "fd --exclude '.git/' --hidden --type d"
if test -f "/usr/local/opt/fzf/shell/key-bindings.fish"
	source /usr/local/opt/fzf/shell/key-bindings.fish
	fzf_key_bindings
end

set --export GPG_TTY (tty)
function encgpg --description "Encrypt stdin with password into a given file"
	gpg -c -o "$argv[1]"
end
function decgpg --description "Decrypt given file into a nvim buffer"
	gpg -d "$argv[1]" | nvim -i NONE -n -;
end

set --export NNN_BMS 'd:~/Downloads;j:~/Junk;p:~/Projects;s:~/Sync;v:/Volumes'
set --export NNN_PLUG 'a:archive;d:fzcd;e:_nvim $nnn*;f:-fzopen;k:-pskill'
function e --description "Starts nnn in the current directory"
	nnn -x $argv
	set --export NNN_TMPFILE ~/.config/nnn/.lastd

	if test -e $NNN_TMPFILE
		source $NNN_TMPFILE
		rm $NNN_TMPFILE
	end
end
