-- Web is definitely not a language but with the cluster fuck that is web tools
-- where everything tries to do everything, but at the same time you need a ton
-- of tools to get thing working.
-- Why does prettier format like 15 different languages?


local vue_root = vim.fn.fnamemodify(
    vim.uv.fs_realpath(vim.fn.exepath("vue-language-server")),
    ":h:h"
)
local vue_language_server_path = vue_root
    .. "/lib/language-tools/packages/language-server"

local tsserver_filetypes =
    { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
local vue_plugin = {
    name = "@vue/typescript-plugin",
    location = vue_language_server_path,
    languages = { "vue" },
    configNamespace = "typescript",
}
local vtsls_config = {
    settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    vue_plugin,
                },
            },
        },
    },
    filetypes = tsserver_filetypes,
}

local ts_ls_config = {
    init_options = {
        plugins = {
            vue_plugin,
        },
    },
    filetypes = tsserver_filetypes,
}

-- -- If you are on most recent `nvim-lspconfig`
-- local vue_ls_config = {}
-- If you are not on most recent `nvim-lspconfig` or you want to override
local vue_ls_config = {
  on_init = function(client)
    client.handlers['tsserver/request'] = function(_, result, context)
      local ts_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'ts_ls' })
      local vtsls_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'vtsls' })
      local clients = {}

      vim.list_extend(clients, ts_clients)
      vim.list_extend(clients, vtsls_clients)

      if #clients == 0 then
        vim.notify('Could not find `vtsls` or `ts_ls` lsp client, `vue_ls` would not work without it.', vim.log.levels.ERROR)
        return
      end
      local ts_client = clients[1]

      local param = unpack(result)
      local id, command, payload = unpack(param)
      ts_client:exec_cmd({
        title = 'vue_request_forward', -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
        command = 'typescript.tsserverRequest',
        arguments = {
          command,
          payload,
        },
      }, { bufnr = context.bufnr }, function(_, r)
          local response = r and r.body
          -- TODO: handle error or response nil here, e.g. logging
          -- NOTE: Do NOT return if there's an error or no response, just return nil back to the vue_ls to prevent memory leak
          local response_data = { { id, response } }

          ---@diagnostic disable-next-line: param-type-mismatch
          client:notify('tsserver/response', response_data)
        end)
    end
  end,
}
vim.lsp.config("vtsls", vtsls_config)
vim.lsp.config("vue_ls", vue_ls_config)
vim.lsp.config("ts_ls", ts_ls_config)
vim.lsp.enable({ "ts_ls", "vue_ls" }) -- If using `ts_ls` replace `vtsls` to `ts_ls`


-- for pug (html templating thingy)
vim.lsp.enable('emmet_language_server')

require("nvim-ts-autotag").setup({
    opts = {
        -- Defaults
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = false, -- Auto close on trailing </
    },
})
-- require('nvim-ts-autotag').setup()

-- native (lua) implementation of the communication with tsserver
-- require("typescript-tools").setup({})

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

require("conform").formatters = {
    ["biome"] = {
        -- prepend_args = { "--indent-style", "space", "--indent-width", "4" },
        -- indentStyle = "space",
        -- indentSize = 4,

        args = {
            "format",
            "--stdin-file-path",
            "$FILENAME",
            "--indent-style",
            "space",
            "--indent-width",
            "4",
            "--line-width",
            "160",
            "--javascript-formatter-quote-style",
            "single",
        },
    },
}

for _, lang in
    ipairs(vim.list_extend({ "json", "yaml", "html", "css" }, js_things))
do
    require("conform").formatters_by_ft[lang] = { "biome" }
end

-- require("lint").linters = {
--     biome = {
--         indentStyle = "space",
--         indentSize = 4,
--     },
-- }
-- for _, lang in ipairs(js_things) do
--     require("lint").linters_by_ft[lang] = { "biomejs" }
-- end
