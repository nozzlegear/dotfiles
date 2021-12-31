#! /usr/bin/env fish

set fileName "$USER-backup-"(date --iso-8601=minutes)".tar.gz"

sudo tar -zcpv \
    --exclude "node_modules" \
    --exclude "packages" \
    --exclude "paket-files" \
    --exclude ".rustup" \
    --exclude ".local/share/Nuget/Cache" \
    --exclude ".local/share/flatpak" \
    --exclude "*irtualBox VMs" \
    --exclude "lutris" \
    --exclude "Games" \
    --exclude "Steam" \
    --exclude ".steam" \
    --exclude "NuGet/v3-cache" \
    --exclude ".vscode-server" \
    --exclude ".mozilla" \
    --exclude ".cache" \
    --exclude ".config/discord/Cache" \
    --exclude "com.discordapp.Discord" \
    --exclude ".dbus" \
    --exclude ".npm/*cache" \
    --exclude "Trash" \
    --exclude "repos/AUR" \
    --exclude "repos/**/*/bin" \
    --exclude "repos/**/*/obj" \
    --exclude "snap" \
    --exclude "*-backup-*.tar.gz" \
    --exclude "*.iso" \
    --exclude "*.deb" \
    --exclude "*.udeb" \
    --exclude "*.exe" \
    -f "/tmp/$fileName" \
    /etc/ssh/ssh_config \
    /etc/ssh/sshd_config \
    ~/

set_color green
echo ""
echo "Home directory backed up to /tmp/$fileName"
set_color normal
