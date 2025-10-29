require "nvchad.mappings"

local util_hover = require "utils.hover"
local util_def = require "utils.definition"
local util_blink = require "utils.blink"
local util_sn = require "utils.section_nav"
local util_git = require "utils.git"
local gs = require "gitsigns"
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Remap scroll down and scroll up binds
vim.api.nvim_set_keymap("n", "<C-j>", "<C-d>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-u>", { noremap = true, silent = true })

-- LSP related mappings with descriptions
map("n", "K", util_hover.hover_with_diagnostics, { desc = "Code Description and diagnostics", table.unpack(opts) })
map("n", "<leader>cd", util_def.definition_popup, { desc = "Code Go to definition", table.unpack(opts) })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", table.unpack(opts) })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Code Rename", table.unpack(opts) })
map("n", "<leader>cu", require("telescope.builtin").lsp_references, { desc = "Code Usages", table.unpack(opts) })

-- Format related mappings
map("n", "<leader>cf", require("conform").format, { desc = "Format File code", table.unpack(opts) })

-- Close blink completion, if it is visible
map("i", "<Esc>", util_blink.close, { expr = true, silent = true, desc = "Blink Close completion" })

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
map({ "n", "x", "o" }, "{", util_sn.section_nav_fn "prev_start", { desc = "Move cursor to block start" })
map({ "n", "x", "o" }, "}", util_sn.section_nav_fn "next_end", { desc = "Move cursor to block end" })

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
map("n", "<leader>gr", util_git.reset_current_line, { desc = "Git Current line reset", table.unpack(opts) })
map("v", "<leader>gr", util_git.reset_selected_lines, { desc = "Git Selected lines reset", table.unpack(opts) })
map("n", "<leader>gR", ":Gitsigns reset_hunk<CR>", { desc = "Git Hunk (section) revert", table.unpack(opts) })
