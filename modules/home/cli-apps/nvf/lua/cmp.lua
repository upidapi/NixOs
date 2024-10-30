----------------------
-- About treesitter --
----------------------
require("nvim-treesitter.configs").setup({
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
    },
})


---------------
-- About cmp --
---------------

-- move this part to a separate file 
-- to avoid exiting before other stuff c:ccc
--[[
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
c   return
enc
cocal snip_status_ok, luasnic = pcall(require, "luasnip")
cf not snip_status_ok then
    return
end
]]--


local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip/loaders/from_vscode").lazy_load()

local kind_icons = {
    Text = "󰊄",
    Method = "",
    Function = "󰡱",
    Constructor = "",
    Field = "",
    Variable = "󱀍",
    Class = "",
    Interface = "",
    Module = "󰕳",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
}
-- find more here: https://www.nerdfonts.com/cheat-sheet
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
        ["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
        -- C-b (back) C-f (forward) for snippet placeholder navigation.
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                nvim_lua = "[NVIM_LUA]",
                path = "[Path]",

                buffer = "[Buffer]",
            })[entry.source.name]
            return vim_item
        end,
    },
    sources = {
        { name = "path" },
        { name = "nvim_lua" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
    },
    confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    experimental = {
        ghost_text = false,
        native_menu = false,
    },
})
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})

-------------------
-- About none-ls --
-------------------
-- format(async)
local async_formatting = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    vim.lsp.buf_request(
        bufnr,
        "textDocument/formatting",
        vim.lsp.util.make_formatting_params({}),
        function(err, res, ctx)
            if err then
                local err_msg = type(err) == "string" and err or err.message
                -- you can modify the log message / level (or ignore it completely)
                vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
                return
            end

            -- don't apply results if buffer is unloaded or has been modified
            if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
                return
            end

            if res then
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
                vim.api.nvim_buf_call(bufnr, function()
                    vim.cmd("silent noautocmd update")
                end)
            end
        end
    )
end
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            -- apply whatever logic you want (in this example, we'll only use null-ls)
            return client.name == "null-ls"
        end,
        bufnr = bufnr,
    })
end
require("null-ls").setup({
    sources = {
        -- you must download code formatter by yourself!
        require("null-ls").builtins.formatting.alejandra,
    },
    debug = false,
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePost", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    async_formatting(bufnr)
                    lsp_formatting(bufnr)
                end,
            })
        end
    end,
})
---------------------
-- About lspconfig --
---------------------
local nvim_lsp = require("lspconfig")

-- Add additional capabilities supported by nvim-cmp
-- nvim hasn't added foldingRange to default capabilities, users must add it manually
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

--Change diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = false,
})

local on_attach = function(bufnr)
    vim.api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = "rounded",
                source = "always",
                prefix = " ",
                scope = "line",
            }
            vim.diagnostic.open_float(nil, opts)
        end,
    })
end

nvim_lsp.nixd.setup({
    on_attach = on_attach(),
    capabilities = capabilities,
    settings = {
        nixd = {
            nixpkgs = {
                expr = "import <nixpkgs> { }",
            },
            formatting = {
                command = { "alejandra" },
            },
            options = {
                -- REF: https://github.com/EmergentMind/nix-config/blob/dev/home/ta/common/core/nixvim/plugins/lspconfig.nix#L48                
                --
                nixos = {
                    expr = [[
                        with builtins; (head (attrValues (
                            (getFlake (getEnv "NIXOS_CONFIG_PATH")).nixosConfigurations
                        )).options
                    ]]
                },
                home_manager = {
                    expr = [[
                        with builtins; (head (attrValues (
                            (getFlake (getEnv "NIXOS_CONFIG_PATH")).homeConfigurations
                        )).options
                    ]]
                },
                -- flake_parts = {
                    -- expr = 'let flake = builtins.getFlake (builtins.getEnv "NIXOS_CONFIG_PATH"); in flake.debug.options // flake.currentSystem.options',
                -- },
            },
        },
    },
})


nvim_lsp.ruff.setup({
  init_options = {
    settings = {
      -- Ruff language server settings go here
    }
  }
})

-------------------
-- About lspsaga --
-------------------
local colors, kind
colors = { normal_bg = "#3b4252" }
require("lspsaga").setup({
    ui = {
        colors = colors,
        kind = kind,
        border = "single",
    },
    outline = {
        win_width = 25,
    },
    lightbulb = {
        enable = false,
    },
    symbol_in_winbar = {
        enable = false,
    },
})
