-- Uses skopeo to get the arch-agnostic manifest digest of a container image
local function get_manifest_digest(opts)
  local buffer = vim.api.nvim_get_current_buf()
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

  local imageName = vim.trim(table.concat(lines, ""))
  local nextCharIsAt = lines[#lines]:sub(1, end_col + 1) == "@"

  if imageName == nil or imageName == "" then
    vim.notify("<image_name> cannot be empty", vim.log.levels.ERROR)
    return nil;
  elseif vim.endswith(imageName, "@") then
    imageName = imageName:sub(1, -2)
  end

  local tempFile = vim.fn.tempname()

  local inspect = vim.system({
    "skopeo", "inspect", "--raw",
    "docker://" .. imageName,
  }, { text = true }):wait()

  if inspect.code ~= 0 then
    vim.fn.delete(tempFile)
    vim.notify("skopeo inspect --raw failed: " .. (inspect.stderr or ""), vim.log.levels.ERROR)
    return nil
  end

  local f = io.open(tempFile, "w")
  if not f then
    vim.fn.delete(tempFile)
    vim.notify("Failed to open temp file " .. tempFile, vim.log.levels.ERROR)
    return nil
  end

  f:write(inspect.stdout)
  f:close()

  local digest = vim.system({ "skopeo", "manifest-digest", tempFile }, { text = true }):wait()
  vim.fn.delete(tempFile)

  if digest.code ~= 0 then
    vim.notify("skopeo manifest-digest failed: " .. (digest.stderr or ""), vim.log.levels.ERROR)
    return nil
  end

  local digestValue = vim.trim(digest.stdout)

  -- Move the cursor to the last character of the selection
  local cursorPos = nextCharIsAt and (end_col + 1) or end_col
  vim.api.nvim_win_set_cursor(0, { end_line, cursorPos })
  --vim.api.nvim_input('$')

  -- Write to the buffer at the end of the selection
  vim.api.nvim_put({ digestValue }, "c", true, true)
end

-- Add :GetManifestDigest command
vim.api.nvim_create_user_command("GetManifestDigest", get_manifest_digest, { range = "%" })
