require("lspconfigs.fish")

vim.lsp.enable({
    "ts_ls",
    "cssls",
    "html-ls",
    "astro",
    "svelte"
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

vim.lsp.config["astro"] = {
    filetypes = { "astro" }
}

vim.lsp.config["svelte"] = {
    filetypes = { "svelte" }
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
