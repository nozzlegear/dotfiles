" NOTE: the default location for nvim's rc file has changed to
" ~/.config/nvim/init.vim
"
" This ~/.nvimrc is not read by default anymore. Instead, you can change
" simlink the file to the config folder:
"
" mkdir -p ~/.config/nvim
" echo 'source ~/.nvimrc' > ~/.config/nvim/init.vim

" Source for configurations:
" https://stackoverflow.com/a/1878984
set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.

set shiftwidth=4    " Indents will have a width of 4

set softtabstop=4   " Sets the number of columns for a TAB

set expandtab       " Expand TABs to spaces

set number          " Shows line numbers

set cursorline      " Highlights the currently selected line

syntax on           " Turns on syntax highlighting
