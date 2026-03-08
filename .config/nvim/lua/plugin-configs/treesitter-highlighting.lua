require'nvim-treesitter'.install {
  "c",
  "lua",
  "vim",
  "vimdoc",
  "sql",
  "elixir",
  "javascript",
  "typescript",
  "c_sharp",
  "fsharp",
  "html",
  "graphql",
  "go",
  "fennel",
  "julia",
  "fish",
  "swift",
  "astro"
}
require "plugin-configs.treesitter-mlr-highlighting"

vim.api.nvim_create_autocmd('FileType', {
  pattern = { "go", "mlr", },
  callback = function() vim.treesitter.start() end,
})
