-- General settings

vim.g.mapleader = " "

-- Undo files
vim.opt.undofile = true
vim.opt.undodir = "$HOME/.cache/"

-- Indentation
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Use System clipboard
vim.opt.clipboard = "unnamedplus"

-- Use mouse
vim.opt.mouse = "a"

-- Nicer UI settings
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.cmdheight = 1

-- Miscellaneous
vim.opt.hidden = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.textwidth = 88
vim.opt.colorcolumn = "+1"
vim.opt.wrap = true
vim.opt.updatetime = 250

local opt = {}
local map = vim.api.nvim_set_keymap

-- global keybinds

-- NvimTree
map("n", "<leader>a", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Pressing y copies any selected text
map("", "<leader>c", '"+y', opt)

-- Open a terminal at the right
map("n", "<C-S-h>", [[<Cmd>vnew term://zsh <CR>]], opt)
-- Open a terminal at the bottom
map("n", "<C-H>", [[<Cmd> split term://zsh | resize 10 <CR>]], opt)
