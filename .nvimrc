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

" Make <CR> to accept selected completion item or notify coc.nvim to format
"inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
"                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Set the filetype of all *.tsx files to typescript.tsx; required for the
" typescript syntax highlighting plugins
" autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx

" set filetypes as typescriptreact
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

set completeopt=menu,menuone,noselect

" Configure language servers

lua << EOF

-- ### 
-- Custom keybindings
-- ###

-- Functional wrapper for mapping custom keybindings
-- Source: https://scribe.nixnet.services/create-custom-keymaps-in-neovim-with-lua-d1167de0f2c2
-- Source: https://gist.github.com/Jarmos-san/d46605cd3a795513526448f36e0db18e#file-example-keymap-lua
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Bind Shift-Tab to the inverse of Tab (Ctrl-D by default)
-- https://stackoverflow.com/a/4766304
map("i", "<S-Tab>", "<C-d>")

-- ###
-- Set up nvim-cmp
-- ###

local cmp = require'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    window = {

    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'vsnip' },
    },
    {
        { name = 'buffer' },
    })
})

-- Use buffer source for '/' and '?'
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Setup cmp's lspconfig
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- ###
-- lspconfig keybindings
-- ###

-- Use `:help vim.diagnostic.*` for documentation on any of the keybound functions
-- https://github.com/neovim/nvim-lspconfig
local opts = { 
    noremap = true,
    silent = true
}
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the keys inside after a language server attaches to the current buffer
local attachBindings = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings. 
    -- <M> is the "meta" key which is NOT super/cmd -- it's alt/option.
    -- <M> does not seem to work on tablet? Or at least when sent through Blink shell.
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<M-i>', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<M-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<M-r>', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<Esc-space>', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'g<space>', vim.lsp.buf.code_action, bufopts)
    -- go next error
    vim.keymap.set('n', 'gne',  vim.diagnostic.goto_next, bufopts)
    -- go previous error
    vim.keymap.set('n', 'gpe', vim.diagnostic.goto_prev, bufopts)
end

-- ###
-- lspconfigs for each language
-- ###

-- NOTE: the attachBindings function must be passed to each language setup

require'lspconfig'.fsautocomplete.setup {
    capabilities = capabilities,
    on_attach = attachBindings,
    cmd = {
        "fsautocomplete", "--adaptive-lsp-server-enabled"
    },
    filetypes = {
        "fsharp"
    },
    init_options = {
        AutomaticWorkspaceInit = true
    }
}

require'lspconfig'.csharp_ls.setup{
    on_attach = attachBindings
}

require'lspconfig'.tsserver.setup{
    on_attach = attachBindings
}

require'lspconfig'.zls.setup{
    on_attach = attachBindings
}
EOF
