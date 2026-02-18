return {
  "mason-org/mason.nvim",
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "SmiteshP/nvim-navic",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "gopls",
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "ts_ls",
      },
      automatic_installation = true,
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local navic = require("nvim-navic")
    navic.setup({})

    local servers = {
      "gopls",
      "lua_ls",
      "pyright",
      "rust_analyzer",
      "ts_ls",
    }

    for _, server in ipairs(servers) do
      vim.lsp.config(server, {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
          end
        end,
      })
    end

    vim.lsp.enable(servers)
  end,
}
