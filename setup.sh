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

# Get Microsoft's Ubuntu 18.04 keys and repository
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
add-apt-repository universe -y
rm packages-microsoft-prod.deb

# Install apt files
apt update
apt install apt-transport-https ca-certificates fsharp dos2unix jq "dotnet-sdk-2.2" nodejs yarn zsh zip unzip unrar p7zip-full mono-complete zsh-syntax-highlighting kpcli pwsh -y

# Install Node globals
bash ./setup-node-global.sh

# GUI programs
if [[ $WSL_running == false ]]; then
    apt install code gnome-shell docker.io firefox-dev chromium-browser redshift devilspie2 vlc konsole deluge -y
    snap install keepassxc vscode --classic
fi

### Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sh setup-pure-zsh.sh
### end Oh-my-zsh
