-- Copies the visual selection to the clipboard
local function copy_to_clipboard(opts)
  local start_line = opts.line1
  local end_line = opts.line2
  local start_col = vim.fn.col("'<") - 1
  local end_col = vim.fn.col("'>")

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 1 then
    lines[1] = lines[1]:sub(start_col + 1, end_col)
  else
    lines[1] = lines[1]:sub(start_col + 1)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end

  local text = table.concat(lines, "\n")
  local in_ssh = vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
  local it2copy = vim.fn.exepath("it2copy")

  if in_ssh and it2copy ~= "" then
    local obj = vim.system({ it2copy }, { stdin = text }):wait()

    if obj.code ~= 0 then
      vim.notify("it2copy failed: " .. obj.stderr, vim.log.levels.ERROR)
    else
      vim.notify("copied: " .. obj.code)
    end
  else
    vim.notify("no it2copy found", vim.log.levels.ERROR)
    vim.fn.setreg("+", text)
  end
end

-- Add :Copy and :Clip commands
vim.api.nvim_create_user_command("Copy", copy_to_clipboard, { range = true })
vim.api.nvim_create_user_command("Clip", copy_to_clipboard, { range = true })

-- Also bind this to <leader>y
-- "x" means visual mode only, without some of the quirks of "v" means "select mode" (slightly different and
-- not what most people think of when they want visual mode)
vim.keymap.set("x", "<leader>y", ":Copy<CR>", { desc = "Copy selection to clipboard" })
