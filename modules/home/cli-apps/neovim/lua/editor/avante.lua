-- https://github.com/yetone/avante.nvim
-- cursor like experience in neovim
-- https://github.com/yetone/avante.nvim/blob/main/lua/avante/config.lua
require("avante").setup({
    provider = "claude",
    claude = {
        api_key_name = "cmd:cat "
            .. vim.fn.expand("~/.secrets/ANTHROPIC_API_KEY"),
        -- if it is a table of string, then default to command.
        -- api_key_name = {"bw","get","notes","anthropic-api-key"},
        model = "claude-3-5-sonnet-20241022", -- claude-3-7-sonnet-20250219
        temperature = 0,
        max_tokens = 4096,
    },

    hints = { enabled = false }
})

-- "When loading the plugin synchronously, we recommend require:ing it sometime after your colorscheme."
--
-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3
