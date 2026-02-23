-- Web is definitely not a language but with the cluster fuck that is web tools
-- where everything tries to do everything, but at the same time you need a ton
-- of tools to get thing working.
-- Why does prettier format like 15 different languages?
require('nvim-ts-autotag').setup({
    opts = {
        -- Defaults
        enable_close = true,      -- Auto close tags
        enable_rename = true,     -- Auto rename pairs of tags
        enable_close_on_slash = false -- Auto close on trailing </
    },
})
-- require('nvim-ts-autotag').setup()


-- native (lua) implementation of the communication with tsserver
require("typescript-tools").setup({})

vim.lsp.enable("tailwindcss")

-- all the same server but for different file types (web shenanigans)
vim.lsp.enable("html")
vim.lsp.enable("cssls")

vim.lsp.config("jsonls", {
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
})
vim.lsp.enable("jsonls")
vim.lsp.config("yamlls", {
    settings = {
        yaml = {
            schemaStore = {
                -- You must disable built-in schemaStore support if you want to use
                -- this plugin and its advanced options like `ignore`.
                enable = true,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
            },
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            }, -- require("schemastore").yaml.schemas()
        },
    },
})
vim.lsp.enable("yamlls")

vim.lsp.enable("svelte")

-- NOTE: deno_fmt is actually dprint which is quite similar to prettier
--  so might switch to that eventually
--  -
--  also prettierd is just prettier but run as a daemon for performance
--  reasons

local js_things =
{ "javascript", "javascriptreact", "typescript", "typescriptreact" }

for _, lang in
ipairs(vim.list_extend({ "json", "yaml", "html", "css" }, js_things))
do
    require("conform").formatters_by_ft[lang] = { "biome-check" }
end

for _, lang in ipairs(js_things) do
    require("lint").linters_by_ft[lang] = { "biomejs" }
end
