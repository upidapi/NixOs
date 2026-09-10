local dap = require("dap")
dap.configurations.rust = dap.configurations.cpp

-- Crates management
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

-- Formatter is fine
require("conform").formatters_by_ft.rust = { "rustfmt" }

-- IMPORTANT: Remove "clippy" from nvim-lint to prevent target/ lock contention!
-- require("lint").linters_by_ft.rust = { "clippy" } -- REMOVED

-- Rustaceanvim automatically starts rust-analyzer (DO NOT use vim.lsp.enable)
vim.g.rustaceanvim = {
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
            ["rust-analyzer"] = {
                -- Let rust-analyzer run clippy on save instead of nvim-lint
                check = {
                    command = "clippy",
                    extraArgs = { "--no-deps" }, -- Speeds up checks by ignoring external deps
                },
                cargo = {
                    allFeatures = true,
                    loadOutDirsFromCheck = true,
                    buildScripts = {
                        enable = true,
                    },
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
}
