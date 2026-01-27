return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,       -- load immediately
    priority = 1000,    -- load before most other plugins
    config = function()
      vim.opt.termguicolors = true

      require("catppuccin").setup({
        flavour = "mocha",
      })

      vim.cmd.colorscheme("catppuccin")
      -- or: vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
}

