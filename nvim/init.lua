-- Source the original vim config file until it's been migrated to lua
vim.cmd("source ~/.nvimrc")

-- Plugins required here are loaded from the lua folder
require("plugins")

require("econfig")

--vim.cmd.colorscheme('onedark')

require('pqf').setup()

require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"

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

-- set termguicolors to enable highlight groups
--vim.opt.termguicolors = true

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
    vim.keymap.set('n', '<C-i>', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<K-r>r', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<Leader>rr', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<Enter><Enter>', vim.lsp.buf.code_action, bufopts)
    -- go next error
    vim.keymap.set('n', 'gne',  vim.diagnostic.goto_next, bufopts)
    -- go previous error
    vim.keymap.set('n', 'gpe', vim.diagnostic.goto_prev, bufopts)

    -- Toggle completions in insert mode
    vim.keymap.set('i', '<C-space>', vim.lsp.buf.completion, bufopts)
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
        "fsharp",
        "fsproj"
    },
    init_options = {
        AutomaticWorkspaceInit = true
    }
}

require'lspconfig'.csharp_ls.setup{
    on_attach = attachBindings,
    init_options = {
        AutomaticWorkspaceInit = true
    },
    handlers = {
      --["textDocument/definition"] = require('csharpls_extended').handler,
    },
    cmd = { "csharp-ls" },
    filetypes = { "cs", "csproj", "razor", "fs" }
    -- Use custom csharp-ls fix until https://github.com/razzmatazz/csharp-language-server/issues/121 is fixed
    --root_dir = require'lspconfig'.util.root_pattern("_.sln", "_.csproj", "packages.config")
}

require'lspconfig'.tsserver.setup{
    on_attach = attachBindings
}

require'lspconfig'.zls.setup{
    on_attach = attachBindings
}

require 'lspconfig'.theme_check.setup{
    on_attach = attachBindings
}

--- """
--- Misc keymappings
--- """

-- Bind Shift-Tab to the inverse of Tab (Ctrl-D by default)
-- https://stackoverflow.com/a/4766304
map("i", "<S-Tab>", "<C-d>")

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "diff" and vim.bo.filetype ~= "gitcommit" then
      vim.cmd '%s/\\s\\+$//e'
    end
  end,
})

-- Make nvim interpret .hbs files as HTML
--vim.filetype.add({
--    extension = { hbs = "html" }
--})
