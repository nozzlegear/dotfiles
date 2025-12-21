-- Git Scope Completion for Neovim
-- Autocompletes scope trailers in git commit messages based on git history
--
-- Usage:
--   1. For basic Neovim completion: Type "scope: " and press <C-x><C-u>
--   2. For nvim-cmp: Uncomment the nvim-cmp section below

-- ============================================================================
-- Basic Neovim Completion (works without plugins)
-- ============================================================================

local function setup_scope_completion()
  -- Only run for git commit messages
  if vim.bo.filetype ~= 'gitcommit' then
    return
  end

  -- Function to get unique scopes from git history
  local function get_scopes()
    local handle = io.popen('git log -200 --pretty=format:%B 2>/dev/null | grep -E "^scope:" | sort -u')
    if not handle then
      return {}
    end

    local result = handle:read("*a")
    handle:close()

    local scopes = {}
    for line in result:gmatch("[^\r\n]+") do
      -- Extract just the scope value (remove "scope: " prefix)
      local scope = line:match("^scope:%s*(.+)$")
      if scope then
        table.insert(scopes, scope)
      end
    end

    return scopes
  end

  -- Custom completion function
  local function complete_scope(findstart, base)
    if findstart == 1 then
      -- Find the start of the word to complete
      local line = vim.api.nvim_get_current_line()

      -- Check if we're on a line starting with "scope:"
      if line:match("^scope:%s*") then
        local start = line:find("scope:%s*")
        return start + 5 -- Return position after "scope: "
      end

      return -3 -- No completion
    else
      -- Return the list of completions
      local scopes = get_scopes()
      local matches = {}

      for _, scope in ipairs(scopes) do
        if base == "" or scope:find(base, 1, true) then
          table.insert(matches, scope)
        end
      end

      return matches
    end
  end

  -- Set the completion function
  vim.bo.completefunc = 'v:lua.require("git_scope_completion").complete_scope'

  -- Store the function globally so it can be called
  _G.git_scope_completion = {
    complete_scope = complete_scope
  }
end

-- Set up an autocommand to run this for gitcommit files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = setup_scope_completion,
})

-- ============================================================================
-- nvim-cmp Integration (optional - uncomment if you use nvim-cmp)
-- ============================================================================

--[[ Uncomment this section if you use nvim-cmp:

local has_cmp, cmp = pcall(require, 'cmp')
if has_cmp then
  -- Custom source for git scopes
  local scope_source = {}

  function scope_source:is_available()
    return vim.bo.filetype == 'gitcommit'
  end

  function scope_source:get_trigger_characters()
    return { ':' }
  end

  function scope_source:complete(params, callback)
    local line = vim.api.nvim_get_current_line()

    -- Only complete on lines starting with "scope:"
    if not line:match("^scope:") then
      callback({ items = {}, isIncomplete = false })
      return
    end

    -- Get scopes from git history
    local handle = io.popen('git log -200 --pretty=format:%B 2>/dev/null | grep -E "^scope:" | sed "s/^scope: *//" | sort -u')
    if not handle then
      callback({ items = {}, isIncomplete = false })
      return
    end

    local result = handle:read("*a")
    handle:close()

    local items = {}
    for scope in result:gmatch("[^\r\n]+") do
      table.insert(items, {
        label = scope,
        kind = cmp.lsp.CompletionItemKind.Keyword,
      })
    end

    callback({ items = items, isIncomplete = false })
  end

  -- Register the source
  cmp.register_source('git_scope', scope_source)

  -- Add to your cmp sources for gitcommit files
  cmp.setup.filetype('gitcommit', {
    sources = {
      { name = 'git_scope' },
      { name = 'buffer' },
    }
  })
end

--]]

return {
  setup = setup_scope_completion
}
