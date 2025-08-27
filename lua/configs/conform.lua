local constants = require "configs.format_const"

local function rustfmt_config_path(width)
  local dir = vim.fn.stdpath "cache" .. "/conform_rustfmt"
  vim.fn.mkdir(dir, "p")
  local path = string.format("%s/rustfmt_%d.toml", dir, width)
  local f = io.open(path, "w")
  f:write("max_width = " .. width .. "\n")
  f:close()
  return path
end

local options = {
  formatters_by_ft = {
    angular = { "prettier" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    css = { "prettier" },
    html = { "prettier" },
    go = { "gofumpt", "golines" },
    java = { "google-java-format" },
    javascript = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    jsx = { "prettier" },
    lua = { "stylua" },
    python = { "black" },
    rust = { "rustfmt" },
    scss = { "prettier" },
    typescript = { "prettier" },
    bash = { "beautysh" },
    sh = { "beautysh" },
    zsh = { "beautysh" },
  },

  formatters = {
    black = {
      command = "black",
      args = { "--quiet", "--line-length", tostring(constants.maxLineLength), "-" },
      stdin = true,
    },

    ["clang-format"] = {
      command = "clang-format",
      args = { string.format("--style={IndentWidth: 4, TabWidth: 4, ColumnLimit: %d}", constants.maxLineLength) },
      stdin = true,
    },

    ["google-java-format"] = {
      command = "google-java-format",
      args = { "--aosp", "-" },
      stdin = true,
    },

    ["rustfmt"] = {
      command = "rustfmt",
      args = { "--emit=stdout", "--config-path", rustfmt_config_path(constants.maxLineLength) },
      stdin = true,
    },

    golines = {
      command = "golines",
      args = { "-m", tostring(constants.maxLineLength) },
      stdin = true,
    },

    prettier = {
      prepend_args = { "--print-width", tostring(constants.maxLineLength) },
    },

    stylua = {
      prepend_args = { "--column-width", tostring(constants.maxLineLength) },
    },
  },
}

require("conform").setup(options)
