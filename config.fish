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

# Custom aliases and functions
alias s 'git status'

if test "$WSL_running" = true
    # This assumes that wsl.conf has been edited to make WSL mount at /c instead of /mnt/c
	set -x r '/c/Users/nozzlegear/repos'
else 
	set -x r ~/repos
end

# Set path to include things like dotnet tools
# https://github.com/fish-shell/fish-shell/issues/527
set -gx PATH ~/.dotnet/tools $PATH

# Docker port stuff
if test "$WSL_running" = true
    set -gx DOCKER_HOST 'tcp://localhost:2375'
end

# Set preferred text editor
set -gx EDITOR nvim

# Fix gpg stuff
set -gx GPG_TTY (tty)

# Use starship prompt
# https://starship.rs
eval (starship init fish)
