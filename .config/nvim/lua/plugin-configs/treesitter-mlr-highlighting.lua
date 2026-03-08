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
