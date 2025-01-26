----auto pairs-----
-- https://github.com/windwp/nvim-autopairs
local npairs = require("nvim-autopairs")
npairs.setup({ map_cr = true })

local Rule = require("nvim-autopairs.rule")

npairs.add_rules({
    Rule("/*", "*/", { "javascript", "typescript", "nix" }),
})
