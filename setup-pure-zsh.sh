# Create a ~/.zshfunctions folder
# Create a ~/.zshextras folder
# Clone sindresorhus/pure into the extras folder
# Clone zsh-syntax-highlighting.zsh into the extras folder
# Offer to add ~/.zshfunctions to the $fpath variable and load Pure Prompt in ~/.zshrc
# Symlink pure.zsh to ~/.zshfunctions with the name prompt_pure_setup
# Symlink async.zsh to ~/.zshfunctions with the name async
# Symlink zsh-syntax-highlighting.zsh to ~/.zshfunctions

zshextras="$HOME/.zshextras"
zshfuncs="$HOME/.zshfunctions"
promptFile="$zshfuncs/prompt_pure_setup"
asyncFile="$zshfuncs/async"
syntaxFile="$zshfuncs/zsh-syntax-highlighting"
line1="ZSH_THEME=\"\" #No zsh theme should be selected when using sindresorhus/pure prompt."
line2="fpath=( \"\$HOME/.zshfunctions\" \$fpath )"
line3="autoload -U promptinit; promptinit"
line4="prompt pure"
line5="source \"$syntaxFile\" #This plugin must be the last thing sourced in your .zshrc file"

if [ ! -d "$zshextras" ]; then 
	mkdir "$zshextras"
fi

if [ ! -d "$zshfuncs" ]; then 
	mkdir "$zshfuncs"
fi

if [ ! -d "$zshextras/pure" ]; then 
	git clone https://github.com/sindresorhus/pure "$zshextras/pure"
else
	echo "It looks like sindresorhus/pure already exists in $zshextras. Skipping repo clone."
fi

if [ ! -d "$zshextras/zsh-syntax-highlighting" ]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zshextras/zsh-syntax-highlighting"
else
	echo "It looks like zsh-users/zsh-syntax-highlighting already exists in $zshextras. Skipping repo clone."
fi

if [ ! -e "$promptFile" ]; then
	ln -s "$zshextras/pure/pure.zsh" "$promptFile"
else 
	echo "$promptFile already exists. Skipping symlink."
fi

if [ ! -e "$asyncFile" ]; then
	ln -s "$zshextras/pure/async.zsh" "$asyncFile"
else
	echo "$asyncFile already exist. Skipping symlink."
fi

if [ ! -e "$syntaxFile" ]; then
	ln -s "$zshextras/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$syntaxFile"
else
	echo "$syntaxFile already exists. Skipping symlink."
fi

# Ask if we should append the configuration to the .zshrc file
read -p "Would you like to append the necessary configuration to your .zshrc file? This may not be necessary if you're using the .zshrc file from nozzlegear/dotfiles. y/n: " -n 1 -r
echo # New line
if [[ $REPLY =~ ^[Yy]$ ]]; then 
	echo $line1 >> "$HOME/.zshrc"
	echo $line2 >> "$HOME/.zshrc"
	echo $line3 >> "$HOME/.zshrc"
	echo $line4 >> "$HOME/.zshrc"
	echo $line5 >> "$HOME/.zshrc"
	echo "Done! Pure Prompt has been setup. Restart your zsh session to begin using it."
else
	echo "To manually add the configuration for Pure Prompt, append the following to your .zshrc file:"
	echo
	echo $line1
	echo $line2
	echo $line3
	echo $line4
	echo $line5
fi
