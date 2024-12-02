-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Mapping for LSP Hover (leader gh)
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "LSP Hover Information" })

-- Mapping for diagnostics: error (leader ge)
vim.keymap.set("n", "ge", vim.diagnostic.open_float, { desc = "Show Error Diagnostics" })

-- Mapping for cutting the selection and entering insert mode at the cursor position
vim.keymap.set("v", "s", '"_d`[i', { desc = "Cut selection and enter insert mode at cursor" })

-- Leader + r to rename symbol under cursor using LSP
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename symbol under cursor" })
