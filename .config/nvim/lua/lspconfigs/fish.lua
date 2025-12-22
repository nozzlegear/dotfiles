local binds = require("keybinds")

vim.lsp.config["fish_lsp"] = {
  cmd = { "fish-lsp", "start" },
  filetypes = { "fish" },
  on_attach = binds.onAttach,
}
