-------------- lsp ----------------
vim.lsp.config("ruff", {
    init_options = {
        settings = {},
    },
})
vim.lsp.enable("ruff")

-- defer hover to pyright
-- vim.api.nvim_create_autocmd("LspAttach", {
--     group = vim.api.nvim_create_augroup(
--         "lsp_attach_disable_ruff_hover",
--         { clear = true }
--     ),
--     callback = function(args)
--         local client = vim.lsp.get_client_by_id(args.data.client_id)
--         if client == nil then
--             return
--         end
--         if client.name == "ruff" then
--             -- Disable hover in favor of Pyright
--             client.server_capabilities.hoverProvider = false
--         end
--     end,
--     desc = "LSP: Disable hover capability from Ruff",
-- })
--
vim.lsp.config("pyright", {
    settings = {
        pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
        },
        python = {
            analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for 
                -- linting
                ignore = { "*" },
            },
        },
    },
})
vim.lsp.enable("pyright")

require("lint").linters_by_ft.python = { "dmypy" }
require("conform").formatters_by_ft = { "ruff" }

require("dap-python").setup(require("passthrough").dap.python)
