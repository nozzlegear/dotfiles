--- buf_picker.lua
--- Opens a fzf-lua floating picker that shows:
---   1. Open buffers (sorted most-recently-used first)
---   2. Unignored project files from the cwd (git ls-files, falling back to fd)
--- Duplicates are suppressed — a file that is already an open buffer won't
--- appear a second time in the file list portion.

local M = {}

function M.open()
    local fzf = require("fzf-lua")

    -- Collect loaded buffers sorted by last-used time (most recent first).
    local bufnrs = vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_loaded(b)
            and vim.api.nvim_buf_get_name(b) ~= ""
            and vim.fn.filereadable(vim.api.nvim_buf_get_name(b)) == 1
    end, vim.api.nvim_list_bufs())

    table.sort(bufnrs, function(a, b)
        local ai = vim.fn.getbufinfo(a)[1] or {}
        local bi = vim.fn.getbufinfo(b)[1] or {}
        return (ai.lastused or 0) > (bi.lastused or 0)
    end)

    -- Build relative-path strings for each buffer and a lookup set for dedup.
    local buf_entries = {}
    local seen        = {}
    for _, bufnr in ipairs(bufnrs) do
        local abs = vim.api.nvim_buf_get_name(bufnr)
        local rel = vim.fn.fnamemodify(abs, ":~:.")
        table.insert(buf_entries, rel)
        seen[rel] = true
    end

    -- Shell command that lists unignored files relative to cwd.
    --   1. jj file list  — works in both colocated and non-colocated jj repos
    --   2. git ls-files  — tracks + untracked-but-not-ignored (colocated jj or plain git)
    --   3. fd            — plain filesystem fallback outside any VCS
    local file_cmd = "jj file list --no-pager 2>/dev/null"
                  .. " || git ls-files --cached --others --exclude-standard 2>/dev/null"
                  .. " || fd --type f --strip-cwd-prefix 2>/dev/null"

    fzf.fzf_exec(function(fzf_cb)
        -- Emit open buffers first so they appear at the top of the list.
        for _, entry in ipairs(buf_entries) do
            fzf_cb(entry)
        end

        -- Stream project files, skipping anything already emitted as a buffer.
        for _, line in ipairs(vim.fn.systemlist(file_cmd)) do
            if line ~= "" and not seen[line] then
                seen[line] = true
                fzf_cb(line)
            end
        end

        fzf_cb() -- signal EOF to fzf
    end, {
        prompt   = "Files❯ ",
        -- Wire up the standard file-open actions (enter, ctrl-x split, ctrl-v vsplit, etc.)
        actions  = fzf.defaults.actions.files,
        winopts  = {
            height  = 0.5,
            width   = 0.7,
            row     = 0.3,
            preview = { hidden = "hidden" },
        },
        -- Let fzf-lua handle path colouring / icons correctly.
        fzf_opts = { ["--tiebreak"] = "index" },
    })
end

--- Open fzf picker and insert relative path (from current file's directory) at cursor.
function M.open_relative()
    local fzf = require("fzf-lua")

    -- Base directory for computing relative paths.
    local current = vim.api.nvim_get_current_buf()
    local abs = vim.api.nvim_buf_get_name(current)
    local base
    if abs ~= "" and vim.fn.filereadable(abs) == 1 then
        base = vim.fn.fnamemodify(abs, ":p:h")
    else
        base = vim.fn.getcwd()
    end

    local rel_action = function(entry)
        local path = entry.path
        -- Compute relative path from base directory.
        local rel = vim.fn.fnamemodify(path, ":." .. base)
        if rel == "" then
            -- fnamemodify returned empty -> fall back to absolute.
            rel = vim.fn.fnamemodify(path, ":p")
        end
        -- Insert at cursor position.
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_buf_set_text(0, line - 1, col, line - 1, col, { rel })
        vim.api.nvim_win_set_cursor(0, { line, col + #rel })
    end

    -- Collect loaded buffers sorted by last-used time (most recent first).
    local bufnrs = vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_loaded(b)
            and vim.api.nvim_buf_get_name(b) ~= ""
            and vim.fn.filereadable(vim.api.nvim_buf_get_name(b)) == 1
    end, vim.api.nvim_list_bufs())

    table.sort(bufnrs, function(a, b)
        local ai = vim.fn.getbufinfo(a)[1] or {}
        local bi = vim.fn.getbufinfo(b)[1] or {}
        return (ai.lastused or 0) > (bi.lastused or 0)
    end)

    -- Build relative-path strings for each buffer and a lookup set for dedup.
    local buf_entries = {}
    local seen = {}
    for _, bufnr in ipairs(bufnrs) do
        local a = vim.api.nvim_buf_get_name(bufnr)
        local r = vim.fn.fnamemodify(a, ":~:.")
        table.insert(buf_entries, r)
        seen[r] = true
    end

    -- Shell command that lists unignored files relative to cwd.
    local file_cmd = "jj file list --no-pager 2>/dev/null"
                  .. " || git ls-files --cached --others --exclude-standard 2>/dev/null"
                  .. " || fd --type f --strip-cwd-prefix 2>/dev/null"

    fzf.fzf_exec(function(fzf_cb)
        for _, entry in ipairs(buf_entries) do
            fzf_cb(entry)
        end
        for _, line in ipairs(vim.fn.systemlist(file_cmd)) do
            if line ~= "" and not seen[line] then
                seen[line] = true
                fzf_cb(line)
            end
        end
        fzf_cb() -- signal EOF to fzf
    end, {
        prompt   = "Files❯ ",
        actions  = vim.tbl_extend("force", fzf.defaults.actions.files, {
            ["default"] = rel_action,
        }),
        winopts  = {
            height  = 0.5,
            width   = 0.7,
            row     = 0.3,
            preview = { hidden = "hidden" },
        },
        fzf_opts = { ["--tiebreak"] = "index" },
    })
end

return M
