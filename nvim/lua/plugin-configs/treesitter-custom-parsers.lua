-- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#available-modules

-- the mlr filetype will use the Go parser (not just Go syntax highlighting)
-- vim.treesitter.language.register('go', 'mlr')

--vim.treesitter.query.set("go", "highlights", [[
--  ; Inherit everything from the default queries
--  (inherits "go")
--  ; Add a new capture for lines starting with '#'
--  ((ERROR) @custom.comment
--    (#match? @custom.comment "^#"))
--]])
