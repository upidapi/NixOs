local ls = require "luasnip"

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
local i = ls.insert_node

local fmt = require("luasnip.extras.fmt").fmt

ls.snippets = {
    lua = {
        ls.parser.parse_snippet("expand", "-- this was expanded")
    }
}

