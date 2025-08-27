return {
  {
    "wakatime/vim-wakatime",
    lazy = false,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "asm",
        "awk",
        "bash",
        "c",
        "c_sharp",
        "cmake",
        "cpp",
        "css",
        "go",
        "haskell",
        "html",
        "json",
        "java",
        "javascript",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "python",
        "ruby",
        "rust",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "xml",
        "yaml",
        "vim",
        "vimdoc",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require "configs.conform"
    end,
  },
  {
    "xzbdmw/colorful-menu.nvim",
    lazy = true,
    main = "colorful-menu",
    opts = {},
  },
  {
    "Saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      { "Saghen/blink.compat", version = "2.*", opts = {} },
      { "hrsh7th/cmp-calc", lazy = true },
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
      { "xzbdmw/colorful-menu.nvim", main = "colorful-menu", opts = {} },
    },
  },
  {
    "towolf/vim-helm",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    opts = {
      ensure_installed = require "configs.mason_tools",
      auto_update = true,
      run_on_start = false,
      start_delay = 0,
      debounce_hours = 24,
    },
  },

  {
    "smoka7/hop.nvim",
    config = function()
      require("hop").setup()
    end,
    event = "BufRead",
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("todo-comments").setup {
        keywords = {
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        },
        colors = {
          hint = { "Hint", "#FBBF24" },
        },
      }
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  },
  {
    "towolf/vim-helm",
    event = { "BufReadPre", "BufNewFile" },
  },
}
