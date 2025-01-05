-- a file for placing custom plugin imports for debugging

-- TODO: remove/comment out when not using

local function ensure_in_path(path)
    -- add config to path if required
    if not string.match(package.path, path) then
        package.path = path .. ";" .. package.path
    end
end

local function hotload_plugin(path)
    ensure_in_path(path .. "/?.lua")
    ensure_in_path(path .. "/?/init.lua")
end

hotload_plugin("/home/upidapi/persist/prog/projects/image.nvim/lua")
