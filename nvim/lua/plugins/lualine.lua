return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    options = {
      theme = "palenight",
      section_separators = { left = "", right = "" },
      component_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff" },
      lualine_c = {},
      lualine_x = {"lsp_status"},
      lualine_y = {},
      lualine_z = {},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    winbar = {
      lualine_c = {
        {
          "filename",
          path = 1,
        },
        {
          function()
            return require("nvim-navic").get_location()
          end,
          cond = function()
            local ok, navic = pcall(require, "nvim-navic")
            return ok and navic.is_available()
          end,
        },
      },
    },
    inactive_winbar = {
      lualine_c = {
        { "filename", path = 1 },
      },
    },
  },
}
