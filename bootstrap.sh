script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
pushd "$script_path" > /dev/null

. misc.sh

printinfo "Installing dotfiles..."
. install-dotfiles.sh ||
{ printinfo "Installing dotfiles... [FAILED]"; exit 1; }

printinfo "Updating keyboard key repeat rate..."
defaults write -g InitialKeyRepeat -int 12 &&
defaults write -g KeyRepeat -int 1 ||
{ printerr "Updating keyboard key repeat rate... FAILED"; exit 1; }


printinfo "Disabling Gatekeeper..."
sudo spctl --master-disable ||
{ printerr "Disabling Gatekeeper... [FAILED]"; exit 1; }


printinfo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" &&
/usr/local/bin/brew doctor ||
{ printinfo "Installing Homebrew... [FAILED]"; exit 1; }


printinfo "Installing Homebrew packages..."
_pkgs_tools=(aria2 bat bash bash-completion@2 coreutils dash entr exa fd ffmpeg
             fish fzf gnupg gocryptfs hey ipfs moreutils neovim ninja nmap nnn p7zip
             progress qemu ripgrep tmux tree youtube-dl zstd)
_pkgs_dev=(cmake gcc gcc@8 gcc@9 git git-delta go grip llvm ninja node@12
           pkg-config python tig)
/usr/local/bin/brew install ${_pkgs_tools[*]} ${_pkgs_dev[*]} ||
{ printinfo "Installing Homebrew packages... [FAILED]"; exit 1; }


printinfo "Installing PIP packages..."
/usr/local/bin/pip3 install --user compiledb pynvim ||
{ printinfo "Installing PIP packages... [FAILED]"; exit 1; }


printinfo "Installing Neovim plugins..."
/usr/local/bin/nvim +PlugInstall +qa &&
/usr/local/bin/nvim +CocUpdateSync +qa ||
{ printinfo "Installing Neovim plugins... [FAILED]"; exit 1; }

printinfo "Installing SF Mono Powerline font..."
curl -L 'https://github.com/Twixes/SF-Mono-Powerline/archive/v16.0d1e1.zip' -o sfmono-powerline.zip &&
unzip -j sfmono-powerline.zip -d sfmono-powerline &&
cp sfmono-powerline/*.otf /Users/psevdaisthisi/Library/Fonts/ &&
rm -rf sfmono-powerline* ||
{ printinfo "Installing Neovim plugins... [FAILED]"; exit 1; }

[ -z "$(grep fish /etc/shells)" ] && {
	printinfo "Changing default shell to Fish..."
	echo "/usr/local/bin/fish" | sudo tee -a /etc/shells &&
	chsh -s /usr/local/bin/fish psevdaisthisi ||
	{ printinfo "Installing Neovim plugins... [FAILED]"; exit 1; }
}

popd > /dev/null
