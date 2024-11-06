function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return "\"" .. tostring(o) .. "\""
    end
end

local options = require("todo-comments.config").options

vim.fn.setreg("+", dump(options))

local categories = {
    "EXPLORE",
    "FIX",
    "HACK",
    "PREF",
    "TODO",
    "WARN",
    -- "NOTE"
}

-- get the names and aliases of the keywords in the
-- categories included
local search_words = {}
for _, keyword in ipairs(categories) do
    local data = options.keywords[keyword]

    if data then
        table.insert(search_words, keyword)
        for i = 1, #search_words do
            table.insert(search_words, data[i])
        end
    end
end

vim.cmd(
    "TodoTelescope keywords=" ..
    table.concat(search_words, ",")
)

