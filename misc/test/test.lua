local function clean(thing)
    if type(thing) == "table" then
        print(type(thing))
        for v, k in pairs(thing) do
            print(type(k))
            if type(k) == "function" then
                thing[v] = nil
            else
                thing[v] = clean(k)
            end
        end

        return thing
    end

    return thing
end

local data = require("conform")
vim.fn.setreg("+", require("lua.helpers.json").encode(data))
