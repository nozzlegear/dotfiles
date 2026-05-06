-- Docs: https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
return function()
    require("mason-tool-installer").setup {
        ensure_installed = {
            "lua-language-server",
            "vim-language-server",
            "json-lsp",
            "taplo",  -- LSP for toml files
        },
        --debounce_hours = 18
    }
end
