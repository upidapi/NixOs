-- This is not the final init.lua but its good to control the order
-- of things.

local modules = {
  "lua.cmp",
}

-- Refresh module cache
for k, v in pairs(modules) do
  package.loaded[v] = nil
  require(v)
end
