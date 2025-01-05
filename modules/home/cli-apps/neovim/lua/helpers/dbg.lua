local function save(data)
    local enc = require("lua.helpers.json").encode(data)
    print(enc)
    vim.fn.setreg("+", enc)
end

save(
    vim.fn.getwininfo()
)

