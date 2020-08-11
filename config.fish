# Fish config
# Note: Fish variables are block scoped. If you want to set one conditionally, you must first declare it outside the block it's being set in.
# https://stackoverflow.com/a/53685510

# Check if running on WSL or native Linux
# https://stackoverflow.com/a/38859331
set -l WSL_running
if grep -q Microsoft /proc/version
    echo "WSL on Windows"
    set WSL_running true 
else
    echo "Native Linux"
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

function tag -a "tagValue" -d "Runs `git tag -s` on the current directory"
    if test -z "$tagValue"
        set_color yellow
        echo "No tag value specified. Usage: `tag 1.2.3`"
        set_color normal
        return 
    end
    git tag -s "$tagValue" -m "$tagValue"
end

if test "$WSL_running" = true
	set -x r '/mnt/c/Users/nozzlegear/repos'
    alias clip 'clip.exe'
else 
	set -x r ~/repos
    alias clip 'xsel --clipboard'
end

# Set path to include things like dotnet tools
# https://github.com/fish-shell/fish-shell/issues/527
set -gx PATH ~/.dotnet/tools ~/.local/bin ~/.yarn/bin $PATH

# Docker port stuff
if test "$WSL_running" = true
    set -gx DOCKER_HOST 'tcp://localhost:2375'
end

# env variables
set -gx ASPNETCORE_ENVIRONMENT "Development"
# Point CurseBreaker to the wow retail directory
# https://github.com/AcidWeb/CurseBreaker
set -gx CURSEBREAKER_PATH "/home/nozzlegear/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_retail_"

# Set preferred text editor
set -gx EDITOR nvim

# Fix gpg stuff
set -gx GPG_TTY (tty)

# Put this function to your .bashrc file.
# Usage: mv oldfilename
# If you call mv without the second parameter it will prompt you to edit the filename on command line.
# Original mv is called when it's called with more than one argument.
# It's useful when you want to change just a few letters in a long name.
#
# Also see:
# - imv from renameutils
# - Ctrl-W Ctrl-Y Ctrl-Y (cut last word, paste, paste)

#function mv() {
#  if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
#    command mv "$@"
#    return
#  fi
#
#  read -ei "$1" newfilename
#  command mv -v -- "$1" "$newfilename"
#}

# Use starship prompt
# https://starship.rs
eval (starship init fish)
