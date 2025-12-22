require("lspconfigs.fish")

vim.lsp.enable({ "ts_ls", "cssls", "html-ls" })

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
