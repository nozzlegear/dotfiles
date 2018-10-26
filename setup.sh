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

### VSCODE
# Install instructions: https://code.visualstudio.com/docs/setup/linux
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
### end VSCODE

### Dotnet
# https://www.microsoft.com/net/core#linuxubuntu
command -v dotnet >/dev/null 2>&1 || {
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg 
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg 
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list' 
    # This is for ubuntu 17.04 zesty 
    # sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-zesty-prod zesty main" > /etc/apt/sources.list.d/dotnetdev.list'
}
### end DOTNET

### NodeJS
# https://nodejs.org/en/download/package-manager/
command -v node >/dev/null 2>&1 || {
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
}
### end NODEJS

### Yarn
# https://yarnpkg.com/en/docs/install
command -v foo >/dev/null 2>&1 || {
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
}
### end Yarn

### Powershell
# https://github.com/PowerShell/PowerShell/blob/fe3e44f3055ccd57e19ce1d29a5320e2f3891705/tools/install-powershell-readme.md
bash <(curl -fsSL https://raw.githubusercontent.com/PowerShell/PowerShell/fe3e44f3055ccd57e19ce1d29a5320e2f3891705/tools/install-powershell.sh)
### end Powershell

# Install apt files
apt update
apt install apt-transport-https ca-certificates fsharp dos2unix jq "dotnet-runtime-2.0.0" "dotnet-sdk-2.0.0" nodejs yarn zsh zip unzip unrar p7zip-full mono-complete gtk-sharp3 zsh-syntax-highlighting kpcli -y

# Install Node globals
bash ./setup-node-global.sh

# GUI programs. Comment out on Windows
# apt install code gnome-shell docker.io firefox-dev chromium-browser redshift devilspie2 vlc konsole deluge -y
# sudo snap install keepassxc

### Docker config
# https://gist.github.com/giggio/d1391ad8fad5dbc9e1256ecbdd7b6d3a
service docker start
systemctl enable docker
docker pull klaemo/couchdb
docker pull postgres
docker run --restart unless-stopped --name couchdb -p 5984:5984 -d klaemo/couchdb
docker run --restart unless-stopped --name posty -e POSTGRES_PASSWORD=dev -e POSTGRES_DB=postgres -e POSTGRES_USER=pg -t -p 0.0.0.0:5432:5432 -d postgres
### end Docker config

### Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sh setup-pure-zsh.sh
### end Oh-my-zsh
