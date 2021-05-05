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

" Remap jk to escape. Tried to remap f13 to escape but can't seem to get it to work
imap jk <esc>

" Add a copy command that copies to clipboard. Added because on Linux my yank to clipboard will paste in everything _but_ rider due to the yank using xsel instead of xclip. 
" https://stackoverflow.com/a/2585673
"function Copy() range 
"    echo system('echo '.shellescape(join(getline(a:firstline, a:listline), "\n")).'| xclip -selection clipboard')
"endfunction
"
" This version works on windows. TODO: figure out how to combine these two
" functions so they're portable
function Copy() range
      echo system('echo '.shellescape(join(getline(a:firstline, a:lastline), "\r")).'| clip.exe')
endfunction   

" This adds the :Copy and :Clip shortcuts, meaning you don't need to do :call Copy()
com -range=% -nargs=0 Copy :<line1>,<line2>call Copy()
com -range=% -nargs=0 Clip :<line1>,<line2>call Copy()

" Plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Plugins here
" Make sure you use single quotes
Plug 'leafgarland/typescript-vim'
" Plug 'ianks/vim-tsx'
Plug 'peitalin/vim-jsx-typescript'

" Initialize plugin system
call plug#end()

" Set the filetype of all *.tsx files to typescript.tsx; required for the
" typescript syntax highlighting plugins
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx
