-- Set up all other plugins that need to be called or configured

-- projeckt0n/github-nvim-theme
require("github-theme").setup({
  options = {
    darken = {
      floats = true,
      sidebars = {
        enable = true,
        list = { "terminal" },
      },
    },
  },
})

-- nvim tree
require("nvim-tree").setup({})

-- treesitter highlighting, plugins managed by HM
require("nvim-treesitter.configs").setup({
  highlight = { enable = true, },
})

-- plugin to comment lines or sections
require("nvim_comment").setup({})

-- show lines to hint indentation
require("indent_blankline").setup({
  show_current_context = true,
  show_current_context_start = true,
  use_treesitter = true,
  filetype_exclude = { "help", "terminal", "dashboard" },
  buftype_exclude = { "terminal" }
})

-- git decorations
require("gitsigns").setup({})

-- automatically add closing brackets
require("nvim-autopairs").setup({
  check_ts = true
})

-- statusline
require("lualine").setup({})
