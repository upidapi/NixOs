local function save(data)
    vim.fn.setreg("+", require("lua.helpers.json").encode(data))
end

save(vim.split(vim.bo[3].filetype, ".", { plain = true }))

save(require("conform").formatters)

--[[
{"markdownlint-cli2":{"condition":"[function]"},"stylua":{"command":"stylua","args":["--indent-type","Spaces","--search-parent-directories","--stdin-filepath","$FILENAME","-"],"meta":{"url":"https://github.com/JohnnyMorganz/StyLua","description":"An opinionated code formatter for Lua."},"range_args":"[function]","cwd":"[function]"}}
--]]
