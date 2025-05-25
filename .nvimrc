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

" Remap window/split navigation
nnoremap <M-l> :wincmd l<CR>
nnoremap <M-h> :wincmd h<CR>
nnoremap <M-j> :wincmd j<CR>
nnoremap <M-k> :wincmd k<CR>

" Keybind -- to open the current directory
nnoremap -- :Ex <enter>

" Keybind gb to swap to the previous file
nnoremap gb :e# <enter>
" TODO: find a way to show a dialog with a list of the most recent files visited here
nnoremap <C-V>x0FFC0 :e# <enter>

" Set the PjsteToggle command to F2 to toggle paste indent on/off
" https://breezewiki.esmailelbob.xyz/vim/wiki/Toggle_auto-indenting_for_code_paste
nnoremap <F2> :set invpaste paste?<CR>
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

function! SwapSwitchArrows() range abort
    :'<,'>s/\(\S.*\) \+=> \+\(.*\),\+$/\2 => \1,/
    "Replacing the text will deselect the lines, so select them again
    let linenum_to_move = a:lastline - a:firstline
    execute a:firstline . "normal! V". linenum_to_move . "j"
    call cursor(a:lastline, indent('.'))
endfunction

function! ChangeIndent(line_number, num_spaces)
    let current_indent = repeat(' ', a:num_spaces)
    let line_content = substitute(getline(a:line_number), '^\s*', '', '')
    call setline(a:line_number, current_indent . line_content)
endfunction

function! SplitFunctionArguments(delimiter) abort
    let l:enter = "\<CR>"
    let l:esc = "\<Esc>"

    let l:starting_pos = getpos(".")
    let l:starting_line = l:starting_pos[1]
    let l:starting_column = l:starting_pos[2]

    " Move the cursor to the beginning of the line and check if it has an
    " opening parens
    call cursor(l:starting_line, 1)

    " This search will move the cursor to the opening parens
    let l:line_has_no_parens = search("(", "c", l:starting_line) != l:starting_line

    " Make sure there's a line to split under the cursor
    if l:line_has_no_parens
        " Move the cursor back to its original position
        call cursor(l:starting_line, l:starting_column)
        echo "No function arguments to split on this line (could not find opening parens)."
        return
    endif

    " Get the indent of the current line
    let l:indent = indent('.')

    " Split the line's arguments. The previous search already moved the cursor
    " to the opening parens.
    execute "normal! a" . l:enter . l:esc
    execute "s/" . a:delimiter . " */" . a:delimiter . "\r/g"
    execute "normal! /)" . l:enter . "i" . l:enter . l:esc
    nohlsearch

    " Cursor is now on the last line with the closing parens. Move its indent
    " back to match the first line's indent.
    let l:ending_line = line(".")

    call ChangeIndent(l:ending_line, l:indent)

    " Now iterate through all the lines between the opening parens and closing
    " parens to shift their indents over by one tab (&shiftwidth).

    let l:iteration = l:starting_line + 1

    while l:iteration < l:ending_line
        call ChangeIndent(l:iteration, l:indent + &shiftwidth)
        let l:iteration = l:iteration + 1
    endwhile

    " Finally, move the cursor onto the closing parens
    call cursor(l:ending_line, l:indent + 1)
endfunction

nnoremap <Leader>sl :call SplitFunctionArguments(",")<CR>

" This adds the :Copy and :Clip shortcuts, meaning you don't need to do :call Copy()
com -range=% -nargs=0 Copy :<line1>,<line2>call Copy()
com -range=% -nargs=0 Clip :<line1>,<line2>call Copy()

" Tell FuzzyFinder to use ripgrep, which will ignore files in .gitignore by
" default. Also tell it to ignore files in the .git folder so a search for
" e.g. 'hooks' doesn't show files in the .git/hooks folder.
let $FZF_DEFAULT_COMMAND = 'rg --files --ignore-vcs --hidden -g "!.git"'

" Configure commenting function to add a space before each comment
let g:NERDSpaceDelims = 1

" Let omnisharp use net6.0
"let g:OmniSharp_server_use_net6 = 1

" Make <CR> to accept selected completion item or notify coc.nvim to format
"inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
"                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Set the filetype of all *.tsx files to typescript.tsx; required for the
" typescript syntax highlighting plugins
" autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx

" set filetypes as typescriptreact
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

set completeopt=menu,menuone,noselect
