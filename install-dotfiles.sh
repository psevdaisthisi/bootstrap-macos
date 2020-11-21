_scriptdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
pushd "$_scriptdir" > /dev/null

[ -z "$XDG_CONFIG_HOME" ] && XDG_CONFIG_HOME="$HOME/.config"

_vimplug_dir="${HOME}/.local/share/nvim/site/autoload"
if [ ! -f "${_vimplug_dir}/plug.vim" ]; then
	_vimplug_url="https://api.github.com/repos/junegunn/vim-plug/contents/plug.vim"
	echo "$0": Downloading "$_vimplug_url" ...
	mkdir -p "$_vimplug_dir"
	curl "$_vimplug_url" -sS -H "Accept:application/vnd.github.v3.raw" -o "${_vimplug_dir}/plug.vim"
fi

mkdir -p \
	"$HOME/.cache/go/build" \
	"$HOME/.cache/go/lib" \
	"$HOME/.cache/go/mod" \
	"$HOME/.cache/ipfs" \
	"$HOME/.local/bin/" \
	"$HOME/.local/bin/go" \
	"$HOME/.gnupg/" \
	"$HOME/.ssh/" \
	"$XDG_CONFIG_HOME" \
	"${XDG_CONFIG_HOME}/fish" \
	"${XDG_CONFIG_HOME}/git" \
	"${XDG_CONFIG_HOME}/nnn/plugins" \
	"${XDG_CONFIG_HOME}/nvim/nerdtree_plugin"

touch ~/.hushlogin
cd dotfiles
cp .bash_profile ~ && ln -sf ~/.bash_profile ~/.bashrc
cp gpg.conf ~/.gnupg/
cp ssh.conf ~/.ssh/config
cp coc-settings.json "${XDG_CONFIG_HOME}/nvim/"
cp config.fish "${XDG_CONFIG_HOME}/fish/"
cp git.conf "${XDG_CONFIG_HOME}/git/config"
cp init.vim "${XDG_CONFIG_HOME}/nvim/"
cp openInNewTab.vim "${XDG_CONFIG_HOME}/nvim/nerdtree_plugin"
cd "${_scriptdir}"

cd plugins
cp nnn/* "${XDG_CONFIG_HOME}/nnn/plugins/"
chmod u+x "${XDG_CONFIG_HOME}/nnn/plugins/"*
cd "${_scriptdir}"

. ~/.bash_profile
mkdir -p "$JUNK" "$MOUNT" "$PROJECTS" "$SYNC"

popd > /dev/null
