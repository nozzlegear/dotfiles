#! /bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "You must run this script as root. Try \`sudo ./setup.sh\`."
    exit 1
fi

# https://stackoverflow.com/a/38859331
if grep -q Microsoft /proc/version; then
    echo "Ubuntu on Windows"
    WSL_running=true
else
    echo "native Linux"
    WSL_running=false
fi

# Copy dotfiles
cp .zshrc ~/
cp .bashrc ~/
cp .gitconfig ~/
cp .vimrc ~/

# Get Microsoft's Ubuntu 18.04 keys and repository
wget -q "https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb"
dpkg --purge packages-microsoft-prod && dpkg -i packages-microsoft-prod.deb
add-apt-repository universe -y
rm packages-microsoft-prod.deb

# Add yarn's apt repository
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Git secret
# http://git-secret.io/installation
echo "deb https://dl.bintray.com/sobolevn/deb git-secret main" | sudo tee -a /etc/apt/sources.list
wget -qO - https://api.bintray.com/users/sobolevn/keys/gpg/public.key | sudo apt-key add -

# Remove 'cmdtest' package which has a 'yarn' alias and may be used by accident
apt remove cmdtest -y

# Install apt files
apt update
apt install apt-transport-https ca-certificates fsharp dos2unix jq "dotnet-sdk-2.2" nodejs yarn zsh zip unzip unrar p7zip-full mono-complete zsh-syntax-highlighting kpcli powershell git-secret docker.io -y

# Install Node globals
bash ./setup-node-globals.sh

# Install fd, a file finding utility
curl -sOL "https://github.com/sharkdp/fd/releases/download/v7.3.0/fd_7.3.0_amd64.deb"
dpkg -i "./fd_7.3.0_amd64.deb"
rm "./fd_7.3.0_amd64.deb"

# Install notes (https://github.com/pimterry/notes)
curl -L https://rawgit.com/pimterry/notes/latest-release/install.sh | bash
# Get notes autocompletion for zsh
curl -L https://rawgit.com/pimterry/notes/latest-release/_notes > _notes
mv _notes /usr/local/share/zsh/site-functions/_notes

# GUI programs
if [[ $WSL_running == false ]]; then
    apt install code gnome-shell firefox-dev chromium-browser redshift devilspie2 vlc konsole deluge -y
    snap install keepassxc vscode --classic
fi

### Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sh setup-pure-zsh.sh
### end Oh-my-zsh
