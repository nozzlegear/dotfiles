local osc52 = require("vim.ui.clipboard.osc52")

-- Copies the visual selection to the clipboard
local function copy_to_clipboard(opts)
  local start_line = opts.line1
  local end_line = opts.line2
  local start_col = vim.fn.col("'<") - 1
  local end_col = vim.fn.col("'>")

  local lines = vim.api.nvim_buf_get_lines(
    0,
    start_line - 1,
    end_line,
    false
  )

  if #lines == 1 then
    lines[1] = lines[1]:sub(start_col + 1, end_col)
  else
    lines[1] = lines[1]:sub(start_col + 1)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end

  local regtype = vim.fn.visualmode()
  local in_ssh = vim.env.SSH_CONNECTION ~= nil
    or vim.env.SSH_CLIENT ~= nil
    or vim.env.SSH_TTY ~= nil

  if in_ssh then
    -- Send OSC 52 directly through Neovim's terminal channel, which iTerm2 will pick up
    osc52.copy("+")(lines, regtype)
    vim.notify("Copied via OSC 52")
  else
    -- Use the local clipboard
    vim.fn.setreg("+", lines, regtype)
    vim.notify("Copied to the clipboard")
  end
end

-- Add :Copy and :Clip commands
vim.api.nvim_create_user_command("Copy", copy_to_clipboard, { range = true })
vim.api.nvim_create_user_command("Clip", copy_to_clipboard, { range = true })

-- Also bind this to <leader>c
-- "x" means visual mode only, without some of the quirks of "v" means "select mode" (slightly different and
-- not what most people think of when they want visual mode)
vim.keymap.set("x", "<leader>c", ":Copy<CR>", {
  desc = "Copy selection to clipboard"
})
