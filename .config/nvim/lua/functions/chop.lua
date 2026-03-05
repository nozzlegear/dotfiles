local function wrap_lines_at(lines, max_width)
  local result = {}
  for _, line in ipairs(lines) do
    if #line < max_width then
      table.insert(result, line)
    else
      local remaining = line
      while #remaining >= max_width do
        local break_at = max_width
        -- Walk back from max_width to find a word boundary
        while break_at > 0 and remaining:sub(break_at, break_at) ~= " " do
          break_at = break_at - 1
        end
        -- No space found, hard break at max_width
        if break_at == 0 then break_at = max_width end
        table.insert(result, remaining:sub(1, break_at - 1))
        remaining = remaining:sub(break_at + 1)
      end
      if #remaining > 0 then
        table.insert(result, remaining)
      end
    end
  end
  return result
end

vim.keymap.set("v", "<leader>gw", function()
  local start_row = vim.fn.line("v") - 1
  local end_row = vim.fn.line(".") - 1
  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
  local wrapped = wrap_lines_at(lines, 70)
  vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, wrapped)
end, { desc = "Wrap selected lines at 70 chars" })
