return function()
    vim.lsp.config["fish_lsp"] = {
      cmd = { "fish-lsp", "start" },
      filetypes = { "fish" },
    }
end
