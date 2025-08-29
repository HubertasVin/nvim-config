require "nvchad.mappings"

local sn = require "utils.section_nav"
local gs = require "gitsigns"
local gsec = require "utils.git_section"
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- LSP related mappings with descriptions
map(
  "n",
  "K",
  require("utils.hover").hover_with_diagnostics,
  { desc = "Code Description and diagnostics", table.unpack(opts) }
)
map(
  "n",
  "<leader>cd",
  require("utils.definition").definition_popup,
  { desc = "Code Go to definition", table.unpack(opts) }
)
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", table.unpack(opts) })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Code Rename", table.unpack(opts) })
map("n", "<leader>cu", require("telescope.builtin").lsp_references, { noremap = true, silent = true })

-- Format related mappings
map("n", "<leader>cf", require("conform").format, { desc = "Format File code", table.unpack(opts) })

-- Close blink completion, if it is visible
map("i", "<Esc>", function()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink and (blink.is_visible and blink.is_visible()) then
    if blink.cancel then
      blink.cancel()
    end
    if blink.hide then
      blink.hide()
    end
    return ""
  end
  return vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
end, { expr = true, silent = true, desc = "Close completion if visible, else Esc" })

-- Open CMD line without holding shift
map("n", ";", ":")
map("v", ";", ":")

-- Custom mapping: Hop to word
map("n", "<leader>fj", "<cmd>HopWord<CR>", { desc = "Hop to word", table.unpack(opts) })

-- Paste without affecting clipboard
map("v", "P", "p", { desc = "Paste (clipboard unaware)", table.unpack(opts) })
map("v", "p", "P", { desc = "Alternate paste (clipboard preserved)", table.unpack(opts) })

-- Change char without yanking
map("n", "s", '"_s', { desc = "Change char" })
map("v", "s", '"_s', { desc = "Change selection" })

-- Remap '>' and '<' to keep selection in visual mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Improved "{" and "}" to move to a non blank line, instead of a blank line
map({ "n", "x", "o" }, "{", sn.section_nav_fn "prev_start", { desc = "Move cursor to block start" })
map({ "n", "x", "o" }, "}", sn.section_nav_fn "next_end", { desc = "Move cursor to block end" })

-- Search and replace
map(
  "n",
  "<leader>ro",
  "<CMD>SearchReplaceSingleBufferOpen<CR>",
  { desc = "SearchReplace Input string", table.unpack(opts) }
)
map(
  "n",
  "<leader>rw",
  "<CMD>SearchReplaceSingleBufferCWord<CR>",
  { desc = "SearchReplace Current word", table.unpack(opts) }
)
map(
  "v",
  "<leader>ro",
  "<CMD>SearchReplaceWithinVisualSelection<CR>",
  { desc = "SearchReplace In current selected area", table.unpack(opts) }
)
map(
  "v",
  "<leader>rs",
  "<CMD>SearchReplaceSingleBufferVisualSelection<CR>",
  { desc = "SearchReplace Selected string", table.unpack(opts) }
)

-- Git
map("n", "<leader>gd", gs.preview_hunk_inline, { desc = "Git Hunk (section) diff", table.unpack(opts) })
map("n", "<leader>gr", gsec.reset_current_line, { desc = "Git Current line reset", table.unpack(opts) })
map("v", "<leader>gr", gsec.reset_selected_lines, { desc = "Git Selected lines reset", table.unpack(opts) })
map("n", "<leader>gR", ":Gitsigns reset_hunk<CR>", { desc = "Git Hunk (section) revert", table.unpack(opts) })
