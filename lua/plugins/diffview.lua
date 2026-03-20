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

--[[
To use diffview merge tool, updates ~/.gitconfig to use neovim as mergetool
Add:
```
[merge]
    tool = diffview
[mergetool "diffview"]
    cmd = nvim -n -c "DiffviewOpen" "$MERGED"
    prompt = false
    keepBackup = false
```

To git config.
--]]
