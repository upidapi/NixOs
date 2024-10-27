-- This is not the final init.lua but its good to control the order
-- of things.

local modules = {
  "lua.cmp",

  "lua.mappings",
  "lua.misc",
  "lua.mouse",
  "lua.reload",
  "lua.spell",
  "lua.text",
  "lua.ui",

  "lua.plugins.cell-auto",
  "lua.plugins.dap",
  "lua.plugins.image",
  "lua.plugins.luasnip",
  "lua.plugins.neorg",
  "lua.plugins.telescope",
  "lua.plugins.toggleterm",
}

-- Refresh module cache
for _, v in pairs(modules) do
  package.loaded[v] = nil
  require(v)
end

