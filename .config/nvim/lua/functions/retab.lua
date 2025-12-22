local function retab_spaces(width)
  width = tonumber(width)
  if not width or width < 1 then
    vim.notify('retab: positive number required', vim.log.levels.ERROR)
    return
  end

  local buf  = vim.api.nvim_get_current_buf()
  local old  = (vim.bo.shiftwidth ~= 0 and vim.bo.shiftwidth) or vim.bo.tabstop
  if old == 0 then old = 4 end

  vim.cmd('%retab!')  -- expand existing tabs so we’re working with spaces only

  local cmd = string.format(
    [[%%s@^\s\+@\=repeat(' ', (strlen(submatch(0)) / %d) * %d)@e]],
    old, width
  )
  vim.api.nvim_buf_call(buf, function() vim.cmd(cmd) end)

  vim.bo.shiftwidth = width
  vim.bo.tabstop    = width
end

-- use :Retab 2, :Retab 4, …
vim.api.nvim_create_user_command(
  'Retab',
  function(o) retab_spaces(o.args) end,
  {
    nargs = 1,
    complete = function(ArgLead, CmdLine, CursorPos)
      local choices = { '2', '4' }
      return vim.tbl_filter(function(n) return n:match('^'..ArgLead) end, choices)
    end,
  }
)
