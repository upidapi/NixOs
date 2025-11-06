-- NOTE: has to be run after lang/ since it modifies the config

local lspconfig = require("lspconfig")

-- vim.config({
--     -- options for vim.diagnostic.config()
--     ---@type vim.diagnostic.Opts
--     diagnostics = {
--         underline = true,
--         update_in_insert = false,
--         virtual_text = {
--             spacing = 4,
--             source = "if_many",
--             prefix = "●",
--             -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
--             -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
--             -- prefix = "icons",
--         },
--         severity_sort = true,
--         signs = {
--             text = {
--                 [vim.diagnostic.severity.ERROR] = require("lua.icons").diagnostics.error,
--                 [vim.diagnostic.severity.WARN] = require("lua.icons").diagnostics.warn,
--                 [vim.diagnostic.severity.HINT] = require("lua.icons").diagnostics.hint,
--                 [vim.diagnostic.severity.INFO] = require("lua.icons").diagnostics.info,
--             },
--         },
--     },
--     -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
--     -- Be aware that you also will need to properly configure your LSP server to
--     -- provide the inlay hints.
--     inlay_hints = {
--         enabled = true,
--         exclude = { "vue" },   -- filetypes for which you don't want to enable inlay hints
--     },
--     -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
--     -- Be aware that you also will need to properly configure your LSP server to
--     -- provide the code lenses.
--     codelens = {
--         enabled = false,
--     },
--     -- add any global capabilities here
--     capabilities = {
--         workspace = {
--             fileOperations = {
--                 didRename = true,
--                 willRename = true,
--             },
--         },
--     },
--     -- options for vim.lsp.buf.format
--     -- `bufnr` and `filter` is handled by the LazyVim formatter,
--     -- but can be also overridden when specified
--     format = {
--         formatting_options = nil,
--         timeout_ms = nil,
--     },
--     -- LSP Server Settings
--     ---@type lspconfig.options
--     servers = {
--         lua_ls = {
--             -- mason = false, -- set to false if you don't want this server to be installed with mason
--             -- Use this to add any additional keymaps
--             -- for specific lsp servers
--             -- ---@type LazyKeysSpec[]
--             -- keys = {},
--             settings = {
--                 Lua = {
--                     workspace = {
--                         checkThirdParty = false,
--                     },
--                     codeLens = {
--                         enable = true,
--                     },
--                     completion = {
--                         callSnippet = "Replace",
--                     },
--                     doc = {
--                         privateName = { "^_" },
--                     },
--                     hint = {
--                         enable = true,
--                         setType = false,
--                         paramType = true,
--                         paramName = "Disable",
--                         semicolon = "Disable",
--                         arrayIndex = "Disable",
--                     },
--                 },
--             },
--         },
--     },
--     -- you can do any additional lsp server setup here
--     -- return true if you don't want this server to be setup with lspconfig
--     ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
--     setup = {
--         -- example to setup with typescript.nvim
--         -- tsserver = function(_, opts)
--         --   require("typescript").setup({ server = opts })
--         --   return true
--         -- end,
--         -- Specify * to use this function as a fallback for any server
--         -- ["*"] = function(server, opts) end,
--     },
-- })

-- since neovim doesn't support snippets by default we have to do it ourselves
-- so here we simply add it for all the configured
--
-- for some reason you cant pass functions as args
local function clean(thing)
    if type(thing) == "table" then
        for v, k in pairs(thing) do
            if type(k) == "function" then
                thing[v] = nil
            else
                thing[v] = clean(k)
            end
        end

        return thing
    end

    return thing
end

for server, config in pairs(require("lspconfig.configs")) do
    -- passing config.capabilities to blink.cmp merges with the capabilities in your
    -- `opts[server].capabilities, if you've defined it
    local cfg = clean(config.manager.config)
    cfg.capabilities = require("blink.cmp").get_lsp_capabilities(cfg)

    cfg.capabilities = vim.tbl_deep_extend("force", cfg.capabilities, {
        {
            textDocument = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            },
        },
    })

    lspconfig[server].setup(cfg)
end
