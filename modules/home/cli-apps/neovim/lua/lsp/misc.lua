--Change diagnostic symbols in the sign column (gutter)
-- local signs = {
--     error = " ",
--     warn  = " ",
--     hint  = " ",
--     info  = " ",
-- }
-- for type, icon in pairs(signs) do
--     local hl = "DiagnosticSign" .. type
--     vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end
--
vim.diagnostic.config({
    underline = true,
    update_in_insert = false,
    virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
        -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
        -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
        -- prefix = "icons",
    },
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = require("lua.icons").diagnostics.error,
            [vim.diagnostic.severity.WARN] = require("lua.icons").diagnostics.warn,
            [vim.diagnostic.severity.HINT] = require("lua.icons").diagnostics.hint,
            [vim.diagnostic.severity.INFO] = require("lua.icons").diagnostics.info,
        },
    },
})

local attach_keymaps = function(client, bufnr) end

-- Enable formatting

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(client, bufnr)
        attach_keymaps(client, bufnr)
    end,
})
