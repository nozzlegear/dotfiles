# https://stackoverflow.com/a/38859331
if grep -q Microsoft /proc/version; then
    echo "Ubuntu on Windows"
    WSL_running=true
else
    echo "native Linux"
    WSL_running=false
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

if [[ $WSL_running == true ]]; then
    alias ps="pwsh.exe -noprofile -c"
    alias lsmb="ls -l --block-size=M"
    alias faas="faas-cli"
    alias ii="explorer.exe"
    alias bogpaddle="cmd.exe /c bogpaddle.cmd"
    #alias pub="ps pub"
    #alias dartanalyzer="ps dartanalyzer"
    #alias dart2js="ps dart2js"
    #alias dartdevc="ps dartdevc"
    #alias stagehand="ps stagehand"  

    # Alias things like dotnet and yarn to the Windows exe version, which ensures VS Code will load the proper Windows versions of packages.
    # If VS Code tries to load the Linux version of packages, it will show a bunch of errors because it doesn't know how to use them.
    alias dotnet="dotnet.exe"
    alias dart="dart.exe"
    alias yarn="cmd.exe /c yarn.cmd"
    alias npm="cmd.exe /c npm.cmd"
    alias node="node.exe"
fi

# Adjust the PATH to point to things like yarn, dotnet, dart, etc.
PATH="$PATH:$HOME/.yarn/bin:$HOME/.dotnet/tools:$HOME/.local/bin:/usr/lib/dart/bin"

# Clipboard alias
if [[ $WSL_running == true  ]]; then
    alias clip="clip.exe"
else
    alias clip="xclip -selection c"
fi

# Load env variables 
. ~/.env

# Fix tilix stuff
# https://gnunn1.github.io/tilix-web/manual/vteconfig/
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi

# Pure zsh theme
if [[ $WSL_running == true ]]; then

    # Windows terminals/shells (including cmder/conemu) do not currently support unicode symbols or emoji, but support is coming
    # https://blogs.msdn.microsoft.com/commandline/2018/11/15/windows-command-line-unicode-and-utf-8-output-text-buffer/
    # In the mean time, set the Pure prompt symbols to something that will show on Windows
    PURE_PROMPT_SYMBOL=ᐅ
    PURE_GIT_DOWN_ARROW=ᐁ
    PURE_GIT_UP_ARROW=ᐃ

fi

# Docker port stuff
if [[ $WSL_running == true ]]; then 
    export DOCKER_HOST=tcp://localhost:2375
fi

ZSH_THEME="" #No zsh theme should be selected when using sindresorhus/pure prompt.
fpath=( "$HOME/.zshfunctions" $fpath )
autoload -U promptinit; promptinit
prompt pure

if [[ $WSL_running == false ]]; then
    # Syntax highlighting plugins do not currently work with zsh in cmder on wsl -- they will make long text overwrite the previous line instead of moving to a new line.
    source "$HOME/.zshfunctions/zsh-syntax-highlighting" #This plugin must be the last thing sourced in your .zshrc file
fi
