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

function ControlEll() 
    if &filetype == "typescript.tsx" || &filetype == "typescript" 
        echo "You pressed the shortcut in a typescript file, calling TSU stuff"
    elseif &filetype == "cs"
        echo "You pressed the shortcut in a C# file, that's wild. Calling omnisharp stuff."
    elseif &filetype == "fs" || &filetype == "fsharp"
        echo "You pressed the shortcut in an F# file, that's also wild. Calling ionide stuff."
    else
        echo "You pressed the ctrl-l shortcut in an unknown file type: " . &filetype "file"
    endif
endfunction

function OpenTypePreview()
    if &filetype == "cs"
        echo "Opening type preview for C# file"
        :OmniSharpPreviewDefinition
    elseif &filetype == "typescript.tsx" || &filetype == "typescript" || &filetype == "typescriptreact"
        echo "Opening type definition for TS file"
        :TsuDefinition
    elseif &filetype == "f#" || &filetype == "fsharp"
        echo "Type previews are unsupported for F# files. Opening full type definition"
        :call g:LanguageClient#textDocument_definition() 
    else
        echo "Unhandled file type \"" . &filetype . "\""
    endif
endfunction

function OpenTypeDefinition()
    if &filetype == "cs"
        echo "Opening type definition for C# file"
        :OmniSharpGotoDefinition
    elseif &filetype == "typescript.tsx" || &filetype == "typescript" || &filetype == "typescriptreact"
        echo "Opening type definition for TS file"
        :TsuDefinition
    elseif &filetype == "f#" || &filetype == "fsharp"
        echo "Opening type definition for F# file"
        :call g:LanguageClient#textDocument_definition() 
    else
        echo "Unhandled file type \"" . &filetype . "\""
    endif
endfunction

nnoremap <C-l> :call ControlEll() <enter>
nnoremap <F12> :call OpenTypePreview() <enter>
nnoremap <F12><F12> :call OpenTypeDefinition() <enter>

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

" Plugins here
" Make sure you use single quotes
"Plug 'leafgarland/typescript-vim'
" Plug 'ianks/vim-tsx'
Plug 'peitalin/vim-jsx-typescript'
" Language client (requirement for ionide-vim)
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
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
" Ionide-vim
Plug 'ionide/Ionide-vim', {
      \ 'do':  'make fsautocomplete',
      \}
" Omnisharp-vim
Plug 'OmniSharp/omnisharp-vim'
" Mint
Plug 'IrenejMarc/vim-mint'
" Typescript
Plug 'Quramy/tsuquyomi'
" More automcomplete stuff
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
" Coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Stylus syntax
Plug 'iloginow/vim-stylus'

" Initialize plugin system
call plug#end()

" Set the filetype of all *.tsx files to typescript.tsx; required for the
" typescript syntax highlighting plugins
" autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx

" set filetypes as typescriptreact
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
