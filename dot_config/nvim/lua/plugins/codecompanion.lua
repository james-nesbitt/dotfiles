if vim.fn.executable("omp") ~= 1 then
  return {}
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      acp = {
        omp = function()
          local helpers = require("codecompanion.adapters.acp.helpers")
          return {
            name = "omp",
            formatted_name = "Oh My Pi",
            type = "acp",
            roles = {
              llm = "assistant",
              user = "user",
            },
            commands = {
              default = { "omp", "acp" },
            },
            defaults = {
              mcpServers = {},
              timeout = 30000,
            },
            parameters = {
              protocolVersion = 1,
              clientCapabilities = {
                fs = { readTextFile = true, writeTextFile = true },
              },
              clientInfo = {
                name = "CodeCompanion.nvim",
                version = "1.0.0",
              },
            },
            handlers = {
              setup = function(self)
                return true
              end,
              auth = function(self)
                return true
              end,
              form_messages = function(self, messages, capabilities)
                return helpers.form_messages(self, messages, capabilities)
              end,
              on_exit = function(self, code) end,
            },
          }
        end,
      },
    },
    interactions = {
      chat = {
        adapter = "omp",
      },
    },
  },
}
