# Things to install:
# Add `docker start couchdb/posty` to startup scripts
# Add `redshift` to startup scripts
# fman (fman.io)
# dropbox
# some kind of music player (spotify?)
# mail program?
# vagrant with Edge
# SSH key
# .vimrc
# .zshrc and .bashrc
# Paper theme

# https://stackoverflow.com/a/38859331
if grep -q Microsoft /proc/version; then
    echo "Ubuntu on Windows"
    WSL_running=true
else
    echo "native Linux"
    WSL_running=false
fi

if [[ $WSL_running == false  ]]; then

    ### VSCODE
    # Install instructions: https://code.visualstudio.com/docs/setup/linux
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    ### Powershell
    # https://github.com/PowerShell/PowerShell/blob/fe3e44f3055ccd57e19ce1d29a5320e2f3891705/tools/install-powershell-readme.md
    bash <(curl -fsSL https://raw.githubusercontent.com/PowerShell/PowerShell/fe3e44f3055ccd57e19ce1d29a5320e2f3891705/tools/install-powershell.sh)

fi

### Dotnet
# https://dotnet.microsoft.com/download/linux-package-manager/ubuntu18-04/sdk-current
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
add-apt-repository universe -y

# Install apt files
apt update
apt install apt-transport-https ca-certificates fsharp dos2unix jq "dotnet-sdk-2.2" nodejs yarn zsh zip unzip unrar p7zip-full mono-complete zsh-syntax-highlighting kpcli -y

# Install Node globals
bash ./setup-node-global.sh

# GUI programs
if [[ $WSL_running == false ]]; then
    apt install code gnome-shell docker.io firefox-dev chromium-browser redshift devilspie2 vlc konsole deluge -y
    snap install keepassxc
fi

### Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sh setup-pure-zsh.sh
### end Oh-my-zsh
