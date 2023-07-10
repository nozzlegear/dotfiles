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

set cmdheight=2     " Sets the bottom command bar to 2 line height. Prevents Ionide's function signatures from showing a 'Press Enter to Continue' command bar

syntax on           " Turns on syntax highlighting

" Remap jk to escape. Tried to remap f13 to escape but can't seem to get it to work
imap jk <esc>

" Keybind ctrl-p to open fuzzyfinder (:FZF command)
nnoremap <C-p> :FZF <enter>

" Keybind -- to open the current directory
nnoremap -- :Ex <enter>

" Keybind \ to swap to the previous file
nnoremap \ :e# <enter>

" Set the PasteToggle command to F2 to toggle paste indent on/off
" https://breezewiki.esmailelbob.xyz/vim/wiki/Toggle_auto-indenting_for_code_paste
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

" Add a copy command that copies to clipboard. Added because on Linux my yank to clipboard will paste in everything _but_ rider due to the yank using xsel instead of xclip. 
" https://stackoverflow.com/a/2585673
"function Copy() range 
"    echo system('echo '.shellescape(join(getline(a:firstline, a:listline), "\n")).'| xclip -selection clipboard')
"endfunction
"
" This version works on windows. TODO: figure out how to combine these two
" functions so they're portable
function Copy() range
      echo system('echo '.shellescape(join(getline(a:firstline, a:lastline), "\r")).'| clip')
endfunction   

" This adds the :Copy and :Clip shortcuts, meaning you don't need to do :call Copy()
com -range=% -nargs=0 Copy :<line1>,<line2>call Copy()
com -range=% -nargs=0 Clip :<line1>,<line2>call Copy()

" Tell FuzzyFinder to use ripgrep, which will ignore files in .gitignore by
" default. Also tell it to ignore files in the .git folder so a search for
" e.g. 'hooks' doesn't show files in the .git/hooks folder. 
let $FZF_DEFAULT_COMMAND = 'rg --files --ignore-vcs --hidden -g "!.git"'

" Plug plugin manager
" https://github.com/junegunn/vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
      silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Language client (requirement for ionide-vim)
"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }
" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf'
" Autocomplete plugin
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" Automatically turn off search highlighting after you're finished searching
Plug 'romainl/vim-cool'

" Neovim language server/config
Plug 'neovim/nvim-lspconfig'

" nvim-cmp provides autocompletion + utilities
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'

" vsnip is required for nvim-cmp
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" Line indent guides
Plug 'lukas-reineke/indent-blankline.nvim'

" Coc.nvim
"Plug 'neoclide/coc.nvim', {'branch': 'release'}

" C# support with omnisharp-vim
"Plug 'OmniSharp/omnisharp-vim'
" Mint
Plug 'IrenejMarc/vim-mint'
" Typescript
"Plug 'Quramy/tsuquyomi'
" JSX syntax
Plug 'peitalin/vim-jsx-typescript'
" F# syntax
Plug 'adelarsq/neofsharp.vim'
" Stylus syntax
Plug 'iloginow/vim-stylus'
" Fish syntax
Plug 'khaveesh/vim-fish-syntax'
" Commenting functions
Plug 'preservim/nerdcommenter'
" Applescript utilities
Plug 'mityu/vim-applescript'
" Nvim lua support for coc
"Plug 'rafcamlet/coc-nvim-lua'
" Neovim statusline
"Plug 'adelarsq/neoline.vim'
" More automcomplete stuff
"Plug 'Shougo/vimproc.vim', {'do' : 'make'}

" Initialize plugin system
call plug#end()

" Configure commenting function to add a space before each comment
let g:NERDSpaceDelims = 1

" Let omnisharp use net6.0
"let g:OmniSharp_server_use_net6 = 1

" Set the filetype of all *.tsx files to typescript.tsx; required for the
" typescript syntax highlighting plugins
" autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx

" set filetypes as typescriptreact
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
