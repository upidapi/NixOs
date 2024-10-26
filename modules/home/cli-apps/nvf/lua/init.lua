-- This is not the final init.lua but its good to control the order
-- of things.

local modules = {
  -- "lua.cmp",
  "lua.reload",
  "lua.spell",
  "lua.luasnip",
  "lua.mouse",
  "lua.text",
  "lua.ui"
}

-- Refresh module cache
for _, v in pairs(modules) do
  package.loaded[v] = nil
  require(v)
end
