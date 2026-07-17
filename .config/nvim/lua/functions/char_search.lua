local function search_char_under_cursor(forward)
  local line = vim.fn.getline('.')
  local col = vim.fn.charcol('.')
  local char = vim.fn.strcharpart(line, col - 1, 1)

  if char == "" then
    return
  end

  local pattern = '\\V' .. vim.fn.escape(char, '\\/?')
  vim.fn.setreg('/', pattern)
  vim.fn.histadd('search', pattern)

  vim.v.searchforward = forward and 1 or 0

  -- Ensure search highlighting is active
  vim.opt.hlsearch = true

  -- Jump to the next/previous occurrence
  local status, err = pcall(vim.cmd, 'normal! n')
  if not status then
    local msg = tostring(err):gsub("^.-:%s*", "")
    vim.api.nvim_echo({{msg, "WarningMsg"}}, false, {})
  end
end

vim.keymap.set("n", "<leader>-*", function()
  search_char_under_cursor(true)
end, { desc = "Search forward for character under cursor" })

vim.keymap.set("n", "<leader>-n", function()
  search_char_under_cursor(false)
end, { desc = "Search backward for character under cursor" })
