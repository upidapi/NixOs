-------------- lsp ----------------
require("lspconfig").ruff.setup({
    init_options = {
        settings = {
            lint = { enable = false },
        },
    },
})

-- defer hover to pyright
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup(
        "lsp_attach_disable_ruff_hover",
        { clear = true }
    ),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
            return
        end
        if client.name == "ruff" then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
        end
    end,
    desc = "LSP: Disable hover capability from Ruff",
})

require("lspconfig").pyright.setup({
    settings = {
        pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
        },
        python = {
            analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { "*" },
            },
        },
    },
})

local function get_file_name()
    return vim.api.nvim_buf_get_name(0)
end
require("lint").linters.ruff.args = {
    "check",
    "--force-exclude",
    "--quiet",
    "--stdin-filename",
    get_file_name,
    "--no-fix",
    "--output-format",
    "json",
    "--config",
    "$NIXOS_CONFIG_PATH/modules/home/cli-apps/neovim/cfg-files/ruff.toml",
    "-",
}
-- TODO: figure out how to only use the "default" config if ruff
--  doesn't find another config in the project

require("lint").linters_by_ft.python = { "ruff" }

require("dap-python").setup(require("passthrough").dap.python)
