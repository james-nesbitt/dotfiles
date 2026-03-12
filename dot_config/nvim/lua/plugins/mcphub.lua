return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install mcp-hub@latest", -- Installs `mcp-hub` node binary globally
  opts = {},
}
