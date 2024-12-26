-- Lazy package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Packages
    { 'stevearc/dressing.nvim', opts = {} },
    { 'akinsho/git-conflict.nvim', version = "*", config = true },
    -- Automatically turn off search highlighting after you're finished searching
    { 'romainl/vim-cool' },
    -- Neovim language server/config
    { 'neovim/nvim-lspconfig' },
    -- nvim-cmp provides autocompletion + utilities
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp-signature-help' },
    -- vsnip is required for nvim-cmp
    { 'hrsh7th/cmp-vsnip' },
    { 'hrsh7th/vim-vsnip' },
    -- Fuzzy Finder
    { 'junegunn/fzf' },
    -- { 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } },
    -- Automatically turn off search highlighting after you're finished searching
    { 'romainl/vim-cool' },
    -- Neovim language server/config
    { 'neovim/nvim-lspconfig' },
    -- Line indent guides
    { 'lukas-reineke/indent-blankline.nvim' },
    -- Coc.nvim
    --{ 'neoclide/coc.nvim', {'branch': 'release'} },
    -- Mint
    { 'IrenejMarc/vim-mint' },
    -- Typescript
    --{ 'Quramy/tsuquyomi' },
    -- JSX syntax
    { 'peitalin/vim-jsx-typescript' },
    -- Stylus syntax
    { 'iloginow/vim-stylus' },
    -- Fish syntax
    { 'khaveesh/vim-fish-syntax' },
    -- Commenting functions
    { 'preservim/nerdcommenter' },
    -- Applescript utilities
    { 'mityu/vim-applescript' },
    -- Nvim lua support for coc
    --{ 'rafcamlet/coc-nvim-lua' },
    -- Neovim statusline
    --{ 'adelarsq/neoline.vim' },
    -- Dotnet
    { 'adelarsq/neofsharp.vim' },
    --{ 'OmniSharp/omnisharp-vim' },
    { 'razzmatazz/csharp-language-server',
      build = {
        "git init",
        -- `--add-source <folder-name>` is the folder containing the .nupkg. `csharp-ls` what dotnet will rename the package to when adding the tool to the system path
        "dotnet pack -c release -o output && \
         dotnet tool install --global --add-source output csharp-ls"
      }
    },
    -- A plugin to visualise and resolve merge conflicts in neovim
    {'akinsho/git-conflict.nvim', version = "*", config = true},
    -- Prettier quickfix/location list windows for NeoVim
    {'yorickpeterse/nvim-pqf'},
    -- Plugin to decompile .NET source code with GoToDefinition in csharp-ls
    --{ 'Decodetalkers/csharpls-extended-lsp.nvim' },
    { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
    { 'nvim-neo-tree/neo-tree.nvim', branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      config = require("./plugin-configs/neo-tree")
    },
    { 'mustache/vim-mustache-handlebars' },
    -- Fish LSP
    { 'ndonfris/fish-lsp',
      build = { "yarn install" },
      config = require("./plugin-configs/fish-lsp")
    },
    { "deponian/nvim-base64",
      version = "*",
      keys = {
        -- Decode/encode selected sequence from/to base64
        -- (mnemonic: [b]ase64)
        { "<Leader>b", "<Plug>(FromBase64)", mode = "x" },
        { "<Leader>B", "<Plug>(ToBase64)", mode = "x" },
      },
      config = function()
        require("nvim-base64").setup()
      end,
    },
})
