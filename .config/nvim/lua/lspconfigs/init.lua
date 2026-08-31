require("lspconfigs.fish")

-- vim.lsp.enable's FileType handler invokes config.root_dir(bufnr, on_dir) and
-- only spawns the client from within on_dir. lspconfig.util.root_pattern returns
-- an old-style (filename) -> string function that never calls on_dir, so clients
-- with that root_dir silently never attach. Wrap it into the new signature.
local function root_dir_from(...)
    local find_root = require("lspconfig.util").root_pattern(...)
    return function(bufnr, on_dir)
        on_dir(find_root(vim.api.nvim_buf_get_name(bufnr)))
    end
end

-- Native .NET server binaries (SharpLsp sidecars, fsautocomplete's apphost) use
-- hostfxr to locate the .NET SDK; Homebrew's layout is not a registered install
-- location, so SDK discovery fails without DOTNET_ROOT and project loading fails
-- with "Could not load file or assembly 'Microsoft.Build.Framework'". cmd_env is
-- the documented ClientConfig field for spawn-time environment variables.

-- Server names must match nvim-lspconfig's lsp/<name>.lua definitions exactly;
-- an unknown name resolves to a config with nil cmd and silently never attaches.
vim.lsp.enable({
    "sharplsp",
    "fsautocomplete",
    "cssls",
    "html",
    "taplo", -- Toml LSP server
    "jsonls",
    --"vim-lsp-server",
    "lua_ls",
    "svelte",
    "astro",
    "ts_ls",
    "yamlls"
})

-- Some filetypes (e.g. lua) get their FileType event during init, before this
-- module loads and registers the enable autocmd - so the client never attaches.
-- vim.lsp.enable's own catch-up guard (vim_did_enter/did_filetype) is false at
-- init time, so re-dispatch its FileType handler once the session is live.
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        vim.schedule(function()
            vim.cmd("doautoall nvim.lsp.enable FileType")
        end)
    end,
})

-- json5 is not in nvim-lspconfig's default jsonls filetypes
vim.lsp.config["jsonls"] = {
    filetypes = { "json", "jsonc", "json5" }
}

vim.lsp.config['pkl-lsp'] = {
    filetypes = { "pkl", "pkl.properties" }
}

-- "svelte.ts" is not in nvim-lspconfig's default svelte filetypes
vim.lsp.config['svelte'] = {
    filetypes = { "svelte", "svelte.ts" }
}

vim.lsp.config['sharplsp'] = {
    cmd = { "/Users/nozzlegear/opt/sharplsp/sharplsp" },
    cmd_env = { DOTNET_ROOT = "/opt/homebrew/opt/dotnet/libexec" },
    root_dir = root_dir_from("*.sln", "*.slnx", "*.csproj", "*.fsproj"),
    filetypes = { "csharp", "cs", "csproj", "razor" },
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
}

vim.lsp.config['fsautocomplete'] = {
    cmd = { "/Users/nozzlegear/.local/share/nvim/mason/bin/fsautocomplete" },
    cmd_env = { DOTNET_ROOT = "/opt/homebrew/opt/dotnet/libexec" },
    root_dir = root_dir_from("*.sln", "*.slnx", "*.fsproj"),
    filetypes = { "fsharp", "fsx", "fsi", "fsproj" },
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
}

vim.lsp.config['zls'] = {
}

vim.lsp.config['julials'] = {
}

vim.lsp.config['theme_check'] = {
}
