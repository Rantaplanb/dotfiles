local vault = vim.fn.expand("~/dev/personal/golden-vault")

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  enabled = function()
    return vim.fn.isdirectory(vault) == 1
  end,
  event = {
    "BufReadPre " .. vault .. "/**.md",
    "BufNewFile " .. vault .. "/**.md",
  },
  dependencies = { "nvim-telescope/telescope.nvim" },
  opts = {
    legacy_commands = false,
    ui = { enable = false },
    workspaces = {
      {
        name = "golden-vault",
        path = vault,
      },
    },
  },
  keys = {
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "Obsidian new note" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Obsidian search" },
    { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Obsidian today" },
  },
}
