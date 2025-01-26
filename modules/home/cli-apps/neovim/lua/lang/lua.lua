require("lint").linters.luacheck.args = {
    "--formatter",
    "plain",
    "--codes",
    "--ranges",
    "--globals",
    "vim",
    "-",
}
require("lint").linters_by_ft.lua = { "luacheck" }

-- redefine to add "--indent-type Spaces"
local util = require("conform.util")
require("conform").formatters.stylua = {
    meta = {
        url = "https://github.com/JohnnyMorganz/StyLua",
        description = "An opinionated code formatter for Lua.",
    },
    command = "stylua",
    args = {
        "--indent-type",
        "Spaces",
        "--search-parent-directories",
        "--stdin-filepath",
        "$FILENAME",
        "-",
    },
    range_args = function(self, ctx)
        local start_offset, end_offset =
            util.get_offsets_from_range(ctx.buf, ctx.range)
        return {
            "--indent-type",
            "Spaces",
            "--search-parent-directories",
            "--stdin-filepath",
            "$FILENAME",
            "--range-start",
            tostring(start_offset),
            "--range-end",
            tostring(end_offset),
            "-",
        }
    end,
    cwd = util.root_file({
        ".stylua.toml",
        "stylua.toml",
    }),
}
require("conform").formatters_by_ft.lua = { "stylua" }

require("lspconfig").lua_ls.setup({})

require("lazydev").setup({})

-- taken from https://www.lazyvim.org/extras/dap/nlua
local dap = require("dap")
dap.configurations.lua = {
    {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance",
    },
}

dap.adapters.nlua = function(callback, config)
    callback({
        type = "server",
        host = config.host or "127.0.0.1",
        port = config.port or 8086,
    })
end

-- TODO: setup a lua debugger
--  https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#local-lua-debugger-vscode
