require("lspconfigs.fish")

vim.lsp.enable({
    --"ts_ls",
    "cssls",
    "html-ls",
    "taplo", -- Toml LSP server
    "json-lsp",
    --"vim-lsp-server",
    "lua-lsp-server",
    "svelte-language-server",
    "astro-language-server",
    "typescript-language-server",
    "yaml-language-server"
})

vim.lsp.config["html-ls"] = {
    filetypes = { "html" }
}

vim.lsp.config["ts_ls"] = {
    filetypes = { "typescript", "typescriptreact" }
}

vim.lsp.config["cssls"] = {
    filetypes = { "css", "scss", "less" }
}

vim.lsp.config["astro-language-server"] = {
    filetypes = { "astro" }
}

vim.lsp.config["taplo"] = {
    filetypes = { "toml" }
}

vim.lsp.config["json-lsp"] = {
    filetypes = { "json", "jsonc", "json5" }
}

vim.lsp.config["yaml-language-server"] = {
    filetypes = { "yaml", "yml" }
}

vim.lsp.config['pkl-lsp'] = {
    filetypes = { "pkl", "pkl.properties" }
}

vim.lsp.config['csharp_ls'] = {
    init_options = {
        AutomaticWorkspaceInit = true
    },
    handlers = {
      --["textDocument/definition"] = require('csharpls_extended').handler,
    },
    cmd = { "csharp-ls" },
    filetypes = { "cs", "csproj", "razor", "fs" }
}

vim.lsp.config['zls'] = {
}

vim.lsp.config['julials'] = {
}

vim.lsp.config['theme_check'] = {
}

vim.lsp.config["typescript-language-server"] = {
    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
}

vim.lsp.config['fsautocomplete'] = {
    -- cmp's lsp capabilities
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
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
