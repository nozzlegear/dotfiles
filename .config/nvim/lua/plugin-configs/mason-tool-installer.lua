-- Docs: https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
return function()
    require("mason-tool-installer").setup {
        ensure_installed = {
            "lua-language-server",
            "vim-language-server",
            "json-lsp",
            "taplo",  -- LSP for toml files
            {"astro-language-server", version = "2.16.8"},
            {"svelte-language-server", version = "0.18.0"},
        },
        auto_update = false
        --debounce_hours = 18
    }
end
