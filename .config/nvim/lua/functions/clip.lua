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

  -- Check if we're in an SSH session. If so, we'll use it2copy, else we'll use vim's own system clipboard
  local in_ssh = vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil

  if in_ssh and vim.fn.executable("it2copy") == 1 then
    vim.fn.system("it2copy", text)
  else
    vim.fn.setreg("+", text)
  end
end

-- Add :Copy and :Clip commands
vim.api.nvim_create_user_command("Copy", copy_to_clipboard, { range = "%" })
vim.api.nvim_create_user_command("Clip", copy_to_clipboard, { range = "%" })

-- Also bind this to <leader>y
vim.keymap.set("v", "<leader>y", ":Copy<CR>", { desc = "Copy selection to clipboard" })
