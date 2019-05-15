if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Plugins here
" Make sure you use single quotes
Plug 'leafgarland/typescript-vim'

" Initialize plugin system
call plug#end()

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

" Set the terminal's title to the title of the file being edited
set title

" Remap jk to escape. Tried to remap f13 to escape but can't seem to get it to work
imap jk <esc>
