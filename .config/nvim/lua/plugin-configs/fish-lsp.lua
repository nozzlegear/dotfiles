return function()
    require("lspconfig").fish_lsp.setup({
      cmd = { "fish-lsp", "start" },
      filetypes = { "fish" },
    })
end
