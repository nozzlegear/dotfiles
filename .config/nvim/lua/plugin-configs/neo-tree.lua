return function()
    require("neo-tree").setup {
      window = {
        mappings = {
          ['e'] = function() vim.api.nvim_exec('Neotree focus filesystem left', true) end,
          ['b'] = function() vim.api.nvim_exec('Neotree focus buffers left', true) end,
          ['g'] = function() vim.api.nvim_exec('Neotree focus git_status left', true) end,
        },
      },
    }

    -- Remap -- and <leader>f to toggling neotree
    vim.keymap.set('n', '--', function () require('neo-tree.command').execute({ reveal = true, source = filesystem, position = left }) end, opts)
    vim.keymap.set('n', '<leader>f', function () require('neo-tree.command').execute({ toggle = true, source = filesystem, position = left }) end, opts)
    -- Remap <leader>x to close neotree
    vim.keymap.set('n', '<leader>x', ':Neotree close<cr>');
end
