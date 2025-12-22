local M = {}

-- Use an on_attach function to only map the keys inside after a language server attaches to the current buffer
function M.onAttach(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    --vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(evt)
        local opts = { buffer = evt.buf }

        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(evt.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- <M> is the "meta" key which is NOT super/cmd -- it's alt/option.
        -- <M> does not seem to work on tablet? Or at least when sent through Blink shell.
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-i>', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<K-r>r', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<Leader>rr', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<Enter><Enter>', vim.lsp.buf.code_action, opts)
        -- go next error
        vim.keymap.set('n', 'gne',  vim.diagnostic.goto_next, opts)
        -- go previous error
        vim.keymap.set('n', 'gpe', vim.diagnostic.goto_prev, opts)

        -- Toggle completions in insert mode
        vim.keymap.set('i', '<C-space>', vim.lsp.buf.completion, opts)
    end,
})

-- Export the module so it can be used in other Lua files
return M;
