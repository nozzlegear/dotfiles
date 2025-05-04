-- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#available-modules

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = { "go", "mlr" },
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    --additional_vim_regex_highlighting = { "go" },
  },
}

local ns = vim.api.nvim_create_namespace("mlr_comment_highlight")

function highlightMlrComments()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      if line:match("^%s*#") then
        vim.api.nvim_buf_add_highlight(bufnr, ns, "Comment", i - 1, 0, -1)
      end
    end
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.mlr",
  callback = function()
    vim.bo.filetype = "go" -- use Go Tree-sitter highlighting
    highlightMlrComments()
  end,
})

vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
  pattern = "*.mlr",
  callback = function()
    highlightMlrComments()
  end,
})
