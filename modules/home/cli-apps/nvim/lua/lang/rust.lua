require("lspconfig").rust_analyzer.setup({})

local dap = require("dap")
-- maybe dont do this since it might be set by rustaceanvim
dap.configurations.rust = dap.configurations.cpp

-- https://github.com/Saecki/crates.nvim
-- A neovim plugin that helps managing crates.io dependencies.
require("crates").setup({
    completion = {
        crates = {
            enabled = true,
        },
    },
    lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
    },
})

require("conform").formatters_by_ft.rust = { "rustfmt" }
require("lint").linters_by_ft.rust = { "clippy" }

vim.g.rustaceanvim = {
    -- LSP
    tools = {
        hover_actions = {
            replace_builtin_hover = false,
        },
    },
    server = {
        on_attach = function(_, bufnr)
            vim.keymap.set("n", "<leader>cR", function()
                vim.cmd.RustLsp("codeAction")
            end, { desc = "Code Action", buffer = bufnr })
            vim.keymap.set("n", "<leader>dr", function()
                vim.cmd.RustLsp("debuggables")
            end, { desc = "Rust Debuggables", buffer = bufnr })
        end,
        default_settings = {
            -- rust-analyzer language server configuration
            ["rust-analyzer"] = {
                cargo = {
                    allFeatures = true,
                    loadOutDirsFromCheck = true,
                    buildScripts = {
                        enable = true,
                    },
                },
                -- Add clippy lints for Rust if using rust-analyzer
                checkOnSave = true,
                -- Enable diagnostics if using rust-analyzer
                diagnostics = {
                    enable = true,
                },
                procMacro = {
                    enable = true,
                    ignored = {
                        ["async-trait"] = { "async_trait" },
                        ["napi-derive"] = { "napi" },
                        ["async-recursion"] = { "async_recursion" },
                    },
                },
                files = {
                    excludeDirs = {
                        ".direnv",
                        ".git",
                        ".github",
                        ".gitlab",
                        "bin",
                        "node_modules",
                        "target",
                        "venv",
                        ".venv",
                    },
                },
            },
        },
    },
    -- dap = {
    --     adapter = {
    --         type = "executable",
    --         command = "lldb-dap",
    --         name = "rustacean_lldb"
    --     }
    -- }
}

dap.configurations.rust = dap.configurations.cpp
