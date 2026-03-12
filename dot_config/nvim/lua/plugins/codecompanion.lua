-- stylua: ignore
if true then return {} end

return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      opts = {
        log_level = "DEBUG",
      },
      interactions = {
        chat = {
          adapter = {
            name = "ollama",
            model = "gemini-3-flash-preview:cloud",
          },
        },
        inline = {
          adapter = {
            name = "ollama",
            model = "gemini-3-flash-preview:cloud",
          },
        },
        cmd = {
          adapter = {
            name = "ollama",
            model = "gemini-3-flash-preview:cloud",
          },
        },
        background = {
          adapter = {
            name = "ollama",
            model = "gemini-3-flash-preview:cloud",
          },
        },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
  },
}
