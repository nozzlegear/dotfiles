-- Persistent clipboard: yank selection to file, paste from file.
-- File is chmod 600 so only the owner can read/write it.
-- /tmp is auto-swept by macOS after 3 days.

local CLIP_FILE = "/tmp/nvim_clipboard"

local function yank_to_file(opts)
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
  local handle = io.open(CLIP_FILE, "w")
  if handle then
    handle:write(text)
    handle:close()
    os.execute("chmod 600 " .. CLIP_FILE)
    vim.notify("yanked to " .. CLIP_FILE)
  else
    vim.notify("failed to open " .. CLIP_FILE, vim.log.levels.ERROR)
  end
end

local function split_lines(text)
  -- Split on newlines, preserving empty lines (mirrors yank's table.concat)
  return vim.split(text, "\n", true)
end

local function paste_from_file()
  local handle = io.open(CLIP_FILE, "r")
  if not handle then
    vim.notify(CLIP_FILE .. " not found", vim.log.levels.WARN)
    return
  end

  local text = handle:read("*a")
  handle:close()

  if #text == 0 then
    vim.notify(CLIP_FILE .. " is empty", vim.log.levels.WARN)
    return
  end

  local lines = split_lines(text)

  -- Check if we have a visual selection (marks exist)
  local has_selection = pcall(vim.fn.line, "'<") and pcall(vim.fn.line, "'>")
  if has_selection then
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local start_col = vim.fn.col("'<") - 1
    local end_col = vim.fn.col("'>")

    -- Replace the visual selection with file contents
    if start_line == end_line then
      -- Single-line partial selection: extract from selection, merge surrounding text
      local buf_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)
      local before = buf_lines[1]:sub(1, start_col)
      local after = buf_lines[1]:sub(end_col + 1)
      if #lines == 1 then
        vim.api.nvim_buf_set_lines(0, start_line - 1, start_line, false, { before .. lines[1] .. after })
      else
        local combined = { before .. lines[1] }
        for i = 2, #lines - 1 do
          table.insert(combined, lines[i])
        end
        table.insert(combined, lines[#lines] .. after)
        vim.api.nvim_buf_set_lines(0, start_line - 1, start_line, false, combined)
      end
    else
      -- Multi-line selection: replace lines, first/last line partial
      local buf_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)
      local first_before = buf_lines[1]:sub(1, start_col)

      buf_lines = vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)
      local last_after = buf_lines[1]:sub(end_col + 1)

      local combined = { first_before .. lines[1] }
      for i = 2, #lines - 1 do
        table.insert(combined, lines[i])
      end
      table.insert(combined, lines[#lines] .. last_after)
      vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, combined)
    end

    -- Move cursor to end of pasted content
    local new_line, new_col = unpack(vim.api.nvim_win_get_cursor(0))
    if #lines > 0 then
      new_col = #lines[#lines]
    end
    vim.api.nvim_win_set_cursor(0, { new_line, new_col })
  else
    -- Normal mode: insert at cursor (original behavior)
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, lines)
    vim.api.nvim_win_set_cursor(0, { line, col })
  end

  vim.notify("pasted from " .. CLIP_FILE)
end

-- User commands
vim.api.nvim_create_user_command("YankToFile", yank_to_file, { range = true })
vim.api.nvim_create_user_command("PasteFromFile", paste_from_file, { range = true })

-- Keybindings
vim.keymap.set("x", "<leader>y", ":YankToFile<CR>", { desc = "Yank selection to file" })
vim.keymap.set("n", "<leader>p", ":PasteFromFile<CR>", { desc = "Paste from file" })
vim.keymap.set("x", "<leader>p", ":PasteFromFile<CR>", { desc = "Replace selection from file" })
