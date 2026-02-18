return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      vim.keymap.set("n", "<leader>gd", gs.preview_hunk, {
        buffer = bufnr,
        desc = "Git: preview hunk",
      })

      vim.keymap.set("n", "<leader>gr", gs.reset_hunk, {
        buffer = bufnr,
        desc = "Git: reset hunk",
      })
    end,
    signs = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "▎" },
      topdelete    = { text = "▎" },
      changedelete = { text = "▎" },
    },
  },
};
