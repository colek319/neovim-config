return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>do", "<cmd>DiffviewOpen origin/main...HEAD<cr>" },
      { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>" },
      { "<leader>dc", "<cmd>DiffviewClose<cr>" },
    },
  },
}
