local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("blink.cmp").get_lsp_capabilities()

local lspconfig = require "lspconfig"
local constants = require "configs.format_const"

local vue_language_server_path = vim.fn.expand "$MASON/packages/vue-language-server/node_modules/@vue/language-server"

local function mason_installed(name)
  local ok, mr = pcall(require, "mason-registry")
  if not ok then
    return false
  end
  local ok_pkg, pkg = pcall(mr.get_package, name)
  if not ok_pkg then
    return false
  end
  return pkg:is_installed()
end

local servers = {
  "angularls",
  "ansiblels",
  "bashls",
  "clangd",
  mason_installed "csharp-language-server" and "csharp_ls" or nil,
  "cssls",
  "dockerls",
  "docker_compose_language_service",
  "html",
  "helm_ls",
  mason_installed "gopls" and "gopls" or nil,
  "jdtls",
  "jsonls",
  "lemminx",
  "lua_ls",
  "sqlls",
  "pylsp",
  "rust_analyzer",
  "tailwindcss",
  "taplo",
  "yamlls",
}

for _, lsp in ipairs(servers) do
  if lsp then
    lspconfig[lsp].setup {
      on_attach = on_attach,
      on_init = on_init,
      capabilities = capabilities,
    }
  end
end

lspconfig.ts_ls.setup {
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path,
        languages = { "vue" },
      },
    },
  },
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
}

lspconfig.volar.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "vue" },
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
}

lspconfig.bashls.setup {
  filetypes = { "sh", "zsh" },
}

lspconfig.sqlls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  root_dir = function(fname)
    return lspconfig.util.root_pattern ".git"(fname) or vim.fs.dirname(fname)
  end,
}

lspconfig.html.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "html", "typescriptreact", "javascriptreact" },
  cmd = { "vscode-html-language-server", "--stdio" },
}

lspconfig.pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = { "W191" },
          maxLineLength = constants.maxLineLength,
        },
      },
    },
  },
}

lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      assist = {
        importGranularity = "module",
        importPrefix = "by_self",
      },
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        command = "clippy",
      },
    },
  },
}

-- Set filetype to helm if detected
lspconfig.yamlls.setup {
  on_attach = function(client, bufnr)
    if vim.bo[bufnr].filetype == "helm" then
      client.stop()
      return
    end
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  filetypes = { "yaml", "yml" },
}

-- Global default border for all LSP float windows
local orig_open_floating = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return orig_open_floating(contents, syntax, opts, ...)
end

vim.diagnostic.config {
  float = { border = "rounded" },
}
