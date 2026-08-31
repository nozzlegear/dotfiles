return function()
    require("neo-tree").setup {
      window = {
        mappings = {
          ['e'] = function() vim.api.nvim_exec('Neotree focus filesystem left', true) end,
          ['b'] = function() vim.api.nvim_exec('Neotree focus buffers left', true) end,
          ['g'] = function() vim.api.nvim_exec('Neotree focus git_status left', true) end,
          ['O'] = function(state) -- Open with `open` for directories and image files, otherwise Neo-tree default
            local node = state.tree:get_node()
            if not node then return end
            local path = node.path or node:get_id()
            local ext = vim.fn.fnamemodify(path, ':e'):lower()
            local is_dir = node.type == 'directory'
            local image_exts = { 'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg', 'tiff', 'tif', 'ico', 'heic', 'heif', 'avif' }
            if is_dir or vim.tbl_contains(image_exts, ext) then
              vim.fn.system('open ' .. vim.fn.shellescape(path))
            else
              vim.cmd('e ' .. vim.fn.fnameescape(path))
            end
          end,
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = false,
          hide_by_name = {
            ".git",
            "thumbs.db"
          },
          never_show = {
            ".DS_Store"
          }
        }
      }
    }

    -- Remap -- and <leader>f to toggling neotree
    vim.keymap.set('n', '--', function () require('neo-tree.command').execute({ reveal = true, source = filesystem, position = left }) end, opts)
    vim.keymap.set('n', '<leader>f', function () require('neo-tree.command').execute({ toggle = true, source = filesystem, position = left }) end, opts)
    -- Remap <leader>x to close neotree
    vim.keymap.set('n', '<leader>x', ':Neotree close<cr>');
end
