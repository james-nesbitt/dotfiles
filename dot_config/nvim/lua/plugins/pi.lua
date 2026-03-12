return {
  "james-nesbitt/pi.nvim",
  config = function()
    require("pi").setup({
      -- Auto-connect on startup
      auto_connect = vim.fn.executable("pi") == 1,

      -- Require approval before applying changes
      approval_mode = true,

      -- Custom keymaps
      keymaps = {
        toggle_panel = "<leader>pt",
        toggle_logs = "<leader>pl",
        toggle_chat = "<leader>pc",
        attach_image = "<leader>pI",
        approve = "<leader>pa",
        reject = "<leader>pr",
      },
    })
  end,
}
