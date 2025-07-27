# Fish config
# Note: Fish variables are block scoped. If you want to set one conditionally, you must first declare it outside the block it's being set in.
# https://stackoverflow.com/a/53685510

# Check if this shell is interactive and should echo (e.g. user controlled) or if it's a script that invoked fish and shouldn't echo.
# https://unix.stackexchange.com/a/278650
function shouldEcho -d "Checks if this script should echo, i.e. it's running as part of the user's shell and not as another script."
    return (status --is-interactive)
end

# Check if running on WSL, Linux or Mac
# https://stackoverflow.com/a/38859331
function isWindows
    if test -f /proc/version
        switch (cat /proc/version)
            case "*Microsoft*" "*microsoft-standard-WSL*"
                return 0
        end
    end
    return 1
end

function isMac
    if test (uname -s) = "Darwin"
        return 0
    end
    return 1
end

# Custom aliases, functions and abbreviations
set -x r ~/repos
set -x sdh "$r/sdh/Books/SDH/Projects"
set -x sb "$r/sdh/Books/ShopifyBilling/ShopifyBilling"
alias cat 'bat'
alias s 'git status --short'
alias gd 'git diff'
alias gdc 'git diff --cached'
alias gap 'git add -p'
alias ls 'eza -ha -F --group-directories-first'
alias ll 'eza -lhFa --group-directories-first --no-permissions --no-user --no-time --git'
# rot13 cipher; usage: echo "hello world" | rot13
alias rot13 "tr 'A-Za-z' 'N-ZA-Mn-za-m'"
alias yt yt-dlp
alias reload "source ~/.config/fish/config.fish"

# Abbreviation for finding the size of a file. When used, expands to du -h
abbr --add size du -hs
# Use dust instead of du for all other operations
# https://github.com/bootandy/dust
abbr --add du dust -rd1
# Abbreviation for downloading just audio from a URL with youtube-dl
abbr --add audio --set-cursor -- yt --extract-audio --audio-format "wav" \""%\""
abbr video yt-dlp --format "best"
# Abbreviation for using fd, improved find utility
abbr find fd --full-path --hidden --ignore-case
# Abbrevation for sd -- a sed replacement
abbr sedr sd --preview
# Tree
abbr --add tree eza --git-ignore --tree --level=5
# Find extension
abbr --add fe fd --full-path --hidden --ignore-case --extension

# Abbreviation for installing software based on the operating system
if isMac
    abbr i brew install
else
    abbr i sudo apt install -y
end

if test "$WSL_running" = true
    set -x u '/mnt/c/Users/nozzlegear'
	set -x r ~/repos
    alias clip 'clip.exe'

    function numlock -d "Toggles numlock on Windows via PowerShell"
        powershell.exe -C "\$wsh = New-Object -ComObject WScript.Shell; \$wsh.SendKeys('{NUMLOCK}')"
    end

    function capslock -d "Toggles capslock on Windows via PowerShell"
        powershell.exe -C "\$wsh = New-Object -ComObject WScript.Shell; \$wsh.SendKeys('{CAPSLOCK}')"
    end
else if isMac
    alias paste 'pbpaste'
    alias vlc "/Applications/VLC.app/Contents/MacOS/VLC"
    alias rider "/Applications/Rider.app/Contents/MacOS/rider"
    alias audacity "/Applications/Audacity.app/Contents/MacOS/Audacity"
    alias webstorm "$HOME/Applications/WebStorm.app/Contents/MacOS/webstorm"
    alias fleet "$HOME/Applications/Fleet.app/Contents/MacOS/fleet"
    # Set $i to the iCloud directory
    set -x i "$HOME/Library/Mobile Documents/com~apple~CloudDocs"
    # Use SecretAgent ssh agent
    set -x SSH_AUTH_SOCK "$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
else
    alias clip 'xsel --clipboard'
end

# Set path to include things like dotnet tools
# https://github.com/fish-shell/fish-shell/issues/527
#set -gx PATH ~/.dotnet ~/.dotnet/tools ~/.local/bin ~/.yarn/bin $PATH ~/.cargo/bin
set -gx PATH ~/.local/bin ~/.yarn/bin $PATH ~/.cargo/bin ~/.dotnet/tools

# Add homebrew shellenv on mac
if isMac
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # Add the homebrew version of Ruby to path, so it comes before the default macos version
    fish_add_path /opt/homebrew/opt/ruby/bin
end

# yt-dlp should be used instead of youtube-dl
if command -q youtube-dl
   and shouldEcho
    set_color yellow
    echo "It looks like youtube-dl is installed, which is frequently out of date compared to other projects that wrap it. You should install yt-dlp instead:"
    set_color normal
    echo "https://github.com/Homebrew/homebrew-core/pull/126066"
else
    function youtube-dl -d "A no-op function which reminds the user that youtube-dl is not installed."
        set_color red
        echo "You do not have youtube-dl installed. You are most likely using yt-dlp, which is aliased to `yt`."
        set_color normal
        return 1
    end
end

# Docker port stuff
if test "$WSL_running" = true
    set -gx DOCKER_HOST 'tcp://localhost:2375'
end

# env variables
if not test -f ~/.config/fish/env.fish
    touch ~/.config/fish/env.fish
end
source ~/.config/fish/env.fish

# Point CurseBreaker to the wow retail directory
# https://github.com/AcidWeb/CurseBreaker
if isWindows
    set -gx CURSEBREAKER_PATH "/mnt/c/Program Files (x86)/World of Warcraft/_retail_"
else if isMac
    set -gx CURSEBREAKER_PATH "/Applications/World of Warcraft/_retail_"
else
    set -gx CURSEBREAKER_PATH "/home/nozzlegear/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_retail_"
end

# Dotnet stuff
set -gx ASPNETCORE_ENVIRONMENT "Development"
# Prevent dotnet watch from opening browser windows
set -gx DOTNET_WATCH_SUPPRESS_LAUNCH_BROWSER 1

# Set preferred text editor to vim
set -gx EDITOR nvim
# Use neovim for manpages (nvim "+:help ft-man-plugin")
set -gx MANPAGER "nvim +Man!"
set -gx MANWIDTH "999"

# Fix gpg stuff
set -gx GPG_TTY (tty)
set -gx PINENTRY_USER_DATA "USE_CURSES=0"

# Set fuzzyfinder (:FZF in vim) to use ripgrep and ignore any files in .gitignore file
set -gx FZF_DEFAULT_COMMAND 'rg --files --ignore-vcs --hidden'

# Solarized dircolors from the Dracula theme for gnome terminal
if command -q dircolors
    and test -f ~/repos/gnome-terminal/dircolors
    eval (dircolors ~/repos/gnome-terminal/dircolors | head -n 1 | sed 's/^LS_COLORS=/set -x LS_COLORS /;s/;$//')
end

# Use starship prompt
# https://starship.rs
eval (starship init fish)
