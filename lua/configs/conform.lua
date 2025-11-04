local constants = require "configs.format_const"

local function indent_for(ft)
	local size = (constants.indent_size and constants.indent_size[ft]) or constants.default_indent_size or 4
	local use_tabs = (constants.expand_tabs and constants.expand_tabs[ft]) or constants.default_expand_tabs or false
	return size, not use_tabs
end

local function rustfmt_config_path(width, indent_size, use_tabs)
	local dir = vim.fn.stdpath "cache" .. "/conform_rustfmt"
	vim.fn.mkdir(dir, "p")
	local path = string.format("%s/rustfmt_%d_%d_%s.toml", dir, width, indent_size, use_tabs and "tabs" or "spaces")
	local f = assert(io.open(path, "w"))
	f:write("max_width = " .. width .. "\n")
	f:write("hard_tabs = " .. tostring(use_tabs) .. "\n")
	f:write("tab_spaces = " .. indent_size .. "\n")
	f:close()
	return path
end

local options = {
	formatters_by_ft = {
		angular = { "prettier" },
		bash = { "beautysh" },
		sh = { "beautysh" },
		zsh = { "beautysh" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		css = { "prettier" },
		html = { "prettier" },
		go = { "gofumpt", "golines" },
		javascript = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		jsx = { "prettier" },
		lua = { "stylua" },
		python = { "black" },
		rust = { "rustfmt" },
		scss = { "prettier" },
		typescript = { "prettier" },
		tsx = { "prettier" },
	},

	formatters = {
		black = {
			command = "black",
			args = function()
				return { "--quiet", "--line-length", tostring(constants.maxLineLength), "-" }
			end,
			stdin = true,
		},

		["clang-format"] = {
			command = "clang-format",
			args = function()
				local indent, use_tabs = indent_for(vim.bo.filetype)
				local style = string.format(
					"--style={UseTab: %s, IndentWidth: %d, TabWidth: %d, ColumnLimit: %d}",
					use_tabs and "Always" or "Never",
					indent,
					indent,
					constants.maxLineLength
				)
				return { style }
			end,
			stdin = true,
		},

		rustfmt = {
			command = "rustfmt",
			args = function()
				local indent, use_tabs = indent_for(vim.bo.filetype)
				local cfg = rustfmt_config_path(constants.maxLineLength, indent, use_tabs)
				return { "--emit=stdout", "--config-path", cfg }
			end,
			stdin = true,
		},

		golines = {
			command = "golines",
			args = function()
				return { "-m", tostring(constants.maxLineLength) }
			end,
			stdin = true,
		},

		prettier = {
			command = "prettier",
			args = function(ctx)
				local indent, use_tabs = indent_for(vim.bo.filetype)

				local ft = vim.bo.filetype
				local ext_map = {
					javascript = "js",
					javascriptreact = "jsx",
					typescript = "ts",
					typescriptreact = "tsx",
					json = "json",
					css = "css",
					scss = "scss",
					html = "html",
					yaml = "yml",
					yml = "yml",
					markdown = "md",
				}
				local fallback = "stdin." .. (ext_map[ft] or "txt")

				local name = (ctx and ctx.filename) or vim.api.nvim_buf_get_name(0)
				if not name or name == "" then
					name = fallback
				end

				return {
					"--stdin-filepath",
					name,
					"--print-width",
					tostring(constants.maxLineLength),
					"--tab-width",
					tostring(indent),
					use_tabs and "--use-tabs" or "--no-use-tabs",
				}
			end,
			stdin = true,
			cwd = require("conform.util").root_file { ".prettierrc", ".prettierrc.json", ".prettierrc.js", "package.json" },
			try_node_modules = true,
		},

		stylua = {
			command = "stylua",
			args = function(ctx)
				local indent, use_tabs = indent_for(vim.bo.filetype)
				local name = (ctx and ctx.filename) or vim.api.nvim_buf_get_name(0)
				if not name or name == "" then
					name = "stdin.lua"
				end

				return {
					"--search-parent-directories",
					"--stdin-filepath",
					name,
					"--column-width",
					tostring(constants.maxLineLength),
					"--indent-type",
					use_tabs and "Tabs" or "Spaces",
					"--indent-width",
					tostring(indent),
					"-",
				}
			end,
			stdin = true,
		},

		beautysh = {
			command = "beautysh",
			args = function()
				local indent = select(1, indent_for(vim.bo.filetype))
				return { "--indent-size", tostring(indent), "$FILENAME" }
			end,
			stdin = false,
		},
	},
}

require("conform").setup(options)
