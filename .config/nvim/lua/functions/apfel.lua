-- Apfel: Apple LLM CLI integration
-- Pipes visual selection to `apfel` with a user prompt, shows response in a float.

local function apfel(opts)
  -- Get the user's prompt
  local prompt = vim.fn.input("apfel: ", "")
  if prompt == "" then return end

  -- Check for visual selection using text marks from visual mode
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local has_selection = opts.range ~= 0
    or (start_pos[2] ~= 0 and end_pos[2] ~= 0)

  local selection_text = nil
  if has_selection then
    local start_line = start_pos[2]
    local start_col = start_pos[3]
    local end_line = end_pos[2]
    local end_col = end_pos[3]

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    if #lines == 1 then
      lines[1] = lines[1]:sub(start_col, end_col)
    else
      lines[1] = lines[1]:sub(start_col)
      lines[#lines] = lines[#lines]:sub(1, end_col)
    end

    selection_text = table.concat(lines, "\n")
  end

  -- Execute apfel with or without piped stdin
  local result
  if has_selection and selection_text then
    result = vim.system({ "apfel", prompt }, { text = true, stdin = selection_text }):wait()
  else
    result = vim.system({ "apfel", prompt }, { text = true }):wait()
  end

  -- Error handling
  if result.code ~= 0 then
    vim.notify("apfel failed: " .. result.stderr, vim.log.levels.ERROR)
    return
  end

  local response = result.stdout

  -- Create a floating buffer window for the response
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "filetype", "text")
  vim.api.nvim_buf_set_name(buf, "*apfel*")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response, "\n", { plain = true }))

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- Close the floating window
  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  -- Yank entire response to system clipboard
  vim.keymap.set("n", "<CR>", function()
    vim.fn.setreg("+", response)
    close_win()
  end, { buffer = buf, nowait = true, silent = true })

  -- Replace original selection with response (only when selection existed)
  if has_selection then
    vim.keymap.set("n", "r", function()
      if vim.api.nvim_buf_is_valid(0) then
        local replace_lines = vim.split(response, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(0, start_pos[2] - 1, end_pos[2], false, replace_lines)
      end
      close_win()
    end, { buffer = buf, nowait = true, silent = true })
  end

  -- Close without action
  vim.keymap.set("n", "q", close_win, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close_win, { buffer = buf, nowait = true, silent = true })
end

vim.api.nvim_create_user_command("Apfel", apfel, { range = "%" })
vim.keymap.set("v", "<leader>a", "<cmd>Apfel<CR>", { desc = "Apfel: AI query with selection" })