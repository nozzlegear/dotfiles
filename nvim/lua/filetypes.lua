-- This file overrides the Vim's default language interpretation for a filetype with a custom language

-- Interpret mlr files as go files
vim.filetype.add({
    extension = { mlr = "go" }
})
