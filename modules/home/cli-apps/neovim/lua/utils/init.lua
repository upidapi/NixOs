local M = {}

local function ensure_in_path(path)
    -- add config to path if required
    if not string.match(package.path, path) then
        package.path = path .. ";" .. package.path
    end
end

function M.hotload_path(path)
    ensure_in_path(path .. "/?.lua")
    ensure_in_path(path .. "/?/init.lua")
end

return M
