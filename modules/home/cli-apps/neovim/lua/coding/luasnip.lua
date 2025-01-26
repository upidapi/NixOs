local ls = require("luasnip")

require("luasnip/loaders/from_vscode").lazy_load()

--[[
ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
  override_builtin = true,
}

require("luasnip.loaders.from_lua").load({
    paths = "$NIXOS_CONFIG_PATH/modules/home/cli-apps/nixvim/snippets"
})
]]

local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
-- local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
-- local l = extras.lambda
local rep = extras.rep
local p = extras.partial
-- local m = extras.match
-- local n = extras.nonempty
-- local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local conds = require("luasnip.extras.expand_conditions")
-- local postfix = require("luasnip.extras.postfix").postfix
-- local types = require("luasnip.util.types")
-- local parse = require("luasnip.util.parser").parse_snippet
-- local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key

ls.cleanup()
ls.add_snippets("all", {
    s(
        "fixme",
        f(function()
            return os.date("FIXME: (%Y-%m-%d) ")
        end)
    ),

    s("time", p(vim.fn.strftime, "%H:%M:%S")),
    s("date", p(vim.fn.strftime, "%Y-%m-%d")),
})

ls.add_snippets("nix", {
    s(
        "nix-cmod",
        fmt(
            [[
        {{
          config,
          lib,
          my_lib,
          ...
        }}: let
          inherit (lib) mkIf;
          inherit (my_lib.opt) mkEnableOpt;
          cfg = config.{};
        in {{
          options.{} = mkEnableOpt "{}";

          config = mkIf cfg.enable {{
            {}
          }};
        }}
        ]],
            {
                f(function()
                    local buf_raw_path = vim.api.nvim_buf_get_name(0)
                    local flake_dir = os.getenv("NIXOS_CONFIG_PATH")
                    if flake_dir == nil then
                        return "$NIXOS_CONFIG_PATH not found"
                    end

                    local re_check = "^" .. flake_dir .. "[.]nix$"
                    if buf_raw_path:find(re_check) ~= nil then
                        return "not in $NIXOS_CONFIG_PATH=" .. flake_dir
                    end

                    local rel = buf_raw_path:sub(
                        (flake_dir .. "/"):len() + 1,
                        -((".nix"):len() + 1)
                    )

                    return rel:gsub("/", ".")
                end, {}, { key = "mod_path" }),
                rep(k("mod_path")),
                i(1),
                i(0),
            }
        )
    ),
})
