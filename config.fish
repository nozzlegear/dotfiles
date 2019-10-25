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
set -x r '/mnt/c/Users/nozzlegear/repos'

# Set path to include things like dotnet tools
# https://github.com/fish-shell/fish-shell/issues/527
set -gx PATH ~/.dotnet/tools $PATH

# Docker port stuff
if test "$WSL_running" = true
    set -gx DOCKER_HOST 'tcp://localhost:2375'
end

# Use starship prompt
# https://starship.rs
eval (starship init fish)
