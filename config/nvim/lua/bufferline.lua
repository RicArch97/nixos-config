-- Set up bufferline, shows open buffers

require("bufferline").setup({
  options = {
    show_buffer_close_icons = true,
    show_close_icon = true,
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local s = " "
      for e, n in pairs(diagnostics_dict) do
        local sym = e == "error" and " "
            or (e == "warning" and " " or "")
        s = s .. n .. sym
      end
      return s
    end,
    separator_style = "thick",
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left"
      }
    },
    show_tab_indicators = true,
  },
})

local opt = { silent = true }
local map = vim.api.nvim_set_keymap

-- adds new buffer and moves to it
map("n", "<C-t>", [[<Cmd>tabnew<CR>]], opt)
-- removing a buffer
map("n", "<S-x>", [[<Cmd>bdelete<CR>]], opt)
-- tabnew and tabprev
map("n", "<S-t>", [[<Cmd>BufferLineCycleNext<CR>]], opt)
map("n", "<S-n>", [[<Cmd>BufferLineCyclePrev<CR>]], opt)
map("n", "gb", [[<Cmd>BufferLinePick<CR>]], opt)
