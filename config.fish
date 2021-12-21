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

function welcome -a os
    if shouldEcho
        echo ""
        set_color "yellow"
        echo -n "❯ "
        set_color normal
        echo "🐟 Fish on $os" 
    end
end

if isWindows
    welcome "WSL"
    set WSL_running true 
else if isMac
    welcome "macOS"
    set WSL_running false 
else
    welcome "Linux"
    set WSL_running false 
end

# Install fish package manager if it doesn't exist
# https://github.com/jorgebucaran/fisher
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    set fisherUrl "https://raw.githubusercontent.com/jorgebucaran/fisher/c142f61e51db3e456ce71180fd541bcfd328fb7b/fisher.fish"
    curl "$fisherUrl" --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
    # Add fish-getopts for script argument parsing
    fisher add jorgebucaran/fish-getopts
end

# Custom aliases and functions
alias s 'git status'
alias gd 'git diff'
alias gdc 'git diff --cached'
alias ls 'exa -hFa --group-directories-first'
alias ll 'exa -lhFa --group-directories-first --no-permissions --no-user --no-time --git'
# Abbreviation for finding the size of a file. When used, expands to du -h
abbr size du -hs
# Abbreviation for downloading just audio from a URL with youtube-dl
abbr audio youtube-dl --extract-audio --audio-format "m4a" 
# Abbreviation for installing software based on the operating system
if isMac
    abbr i brew install
else
    abbr i sudo apt install -y
end
# rot13 cipher; usage: echo "hello world" | rot13
alias rot13 "tr 'A-Za-z' 'N-ZA-Mn-za-m'"
set -x r ~/repos

function tag -a "tagValue" -d "Runs `git tag -s` on the current directory"
    if test -z "$tagValue"
        set_color yellow
        echo "No tag value specified. Usage: `tag 1.2.3`"
        set_color normal
        return 1
    end
    git tag -s "$tagValue" -m "$tagValue"
end

function ctag -a "tagValue" -d "Commits and tags the current directory"
    if test -z "$tagValue"
        set_color yellow
        echo "No tag value specified. Usage: `ctag 1.2.3`"
        set_color normal
        return 1
    end

    # Ensure there are files staged for commit
    # Source: https://stackoverflow.com/a/3162492
    set -l count (git diff --cached --numstat | wc -l)

    if test "$count" -lt 1
        set_color yellow
        echo "No files are staged for commit. Either stage files to commit, or use the `tag` function to skip committing and only tag the last commit."
        set_color normal
        return 1
    end

    git commit -m "$tagValue";
    and tag "$tagValue";
end

# A function to check the expiration date of an SSL certificate
function ssl_expiry -a "domain" -d "Gets the SSL certificate expiration date for the given website"
    echo | openssl s_client -connect "$domain:443" 2>/dev/null | openssl x509 -noout -enddate
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
else 
    alias clip 'xsel --clipboard'
end

# Set path to include things like dotnet tools
# https://github.com/fish-shell/fish-shell/issues/527
set -gx PATH ~/.dotnet ~/.dotnet/tools ~/.local/bin ~/.yarn/bin $PATH ~/.cargo/bin

# Docker port stuff
if test "$WSL_running" = true
    set -gx DOCKER_HOST 'tcp://localhost:2375'
end

# env variables
if not test -f ~/.config/fish/env.fish
    touch ~/.config/fish/env.fish
end
source ~/.config/fish/env.fish
set -gx ASPNETCORE_ENVIRONMENT "Development"

# Point CurseBreaker to the wow retail directory
# https://github.com/AcidWeb/CurseBreaker
if isWindows
    set -gx CURSEBREAKER_PATH "/mnt/c/Program Files (x86)/World of Warcraft/_retail_"
else if isMac
    set -gx CURSEBREAKER_PATH "/Applications/World of Warcraft/_retail_"
else
    set -gx CURSEBREAKER_PATH "/home/nozzlegear/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_retail_"
end

# Prevent dotnet watch from opening browser windows
set -gx DOTNET_WATCH_SUPPRESS_LAUNCH_BROWSER 1

# Set preferred text editor
set -gx EDITOR nvim

# Fix gpg stuff
set -gx GPG_TTY (tty)

# Set fuzzyfinder (:FZF in vim) to use ripgrep and ignore any files in .gitignore file
set -gx FZF_DEFAULT_COMMAND 'rg --files --ignore-vcs --hidden'

# Attempting to make x11 server work in WSL
if test "$WSL_running" = true
    set -gx DISPLAY (cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
end

# Use starship prompt
# https://starship.rs
eval (starship init fish)
