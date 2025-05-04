-- Source the original vim config file until it's been migrated to lua
vim.cmd("source ~/.nvimrc")

-- Plugins required here are loaded from the lua folder
require("plugins")
require("econfig")
require("filetypes")
require("plugin-configs/treesitter-highlighting")
require("plugin-configs/treesitter-custom-parsers")

--vim.cmd.colorscheme('onedark')

require('pqf').setup()

require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"

-- ###
-- Custom keybindings
-- ###

-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
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

require'lspconfig'.ts_ls.setup{
    on_attach = attachBindings
}

require'lspconfig'.zls.setup{
    on_attach = attachBindings
}

require'lspconfig'.julials.setup{
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

-- Define a function to toggle the terminal buffer
local function toggle_terminal()
  local term_buf = nil

  -- Iterate over all buffers to find one with buftype 'terminal'
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
        term_buf = buf
        break
    end
  end

  if term_buf then
    -- If a terminal buffer exists, open it in a vertical split.
    vim.cmd('vsplit')
    vim.cmd('buffer ' .. term_buf)
  else
    -- Otherwise, create a new terminal buffer
    vim.cmd('vsplit term://fish')
  end
end

local function hide_tool_windows()
    -- Lua's string.find is not true regex, and the hyphen has a special meaning.
    -- It must be escaped with '%'
    local neotreeSearchStr = 'neo%-tree'

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            local bufname = vim.fn.bufname(buf)
            if vim.bo[buf].buftype == 'terminal' then
                local mode = vim.api.nvim_get_mode()["mode"]
                if mode == "t" then
                    vim.api.nvim_feedkeys("<C-\\><C-n>", "n", false)
                end
                vim.cmd(':hide')
            elseif string.find(bufname, neotreeSearchStr) then
                vim.cmd(':Neotree close');
            end
        end
    end
end

-- Bind <leader>t to opening a vertical terminal
map("n", "<leader>t", toggle_terminal)
-- Bind <leader>t to exit terminal-mode
map("t", "<leader>t", "<C-\\><C-n>")
-- Bind <leader>x to hide the opened terminal
map({"t", "n"}, "<leader>x", hide_tool_windows)

-- Rebind x and Del keys to delete without overwriting the paste register
map("n", "<Del>", '"_x', opts)
map("n", "x", '"_x', opts)

-- Commenting (https://github.com/prdanelli/dotfiles/blob/41b5f75aabfcf77f25348d8d42c46281eb37df61/neovim/lua/config/keymaps.lua#L29)
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Insert relative/full path to current file
map("n", "<leader>yr", "<cmd>let @+ = expand('%:~:.')<cr>", { desc = "Relative Path", silent = true })
map("n", "<leader>yf", "<cmd>let @+ = expand('%:p')<cr>", { desc = "Full Path", silent = true })

-- Diagnostic keymaps
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "[Q]uickfix list" })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "diff" and vim.bo.filetype ~= "gitcommit" then
      vim.cmd '%s/\\s\\+$//e'
    end
  end,
})
