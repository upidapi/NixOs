
--[=[
-- Cross-platform function to get all Lua files in a directory recursively
local function get_lua_files(dir)
    local files = {}
    local pfile

    -- Use platform-specific commands for directory listing
    if package.config:sub(1, 1) == "\\" then
        -- Windows: use 'dir /B /S' to list files recursively
        pfile = io.popen('dir "' .. dir .. '" /B /S')
    else
        -- Unix-like (Linux, macOS): use 'find' to list files recursively
        pfile = io.popen('find "' .. dir .. '" -type f')
    end

    for file in pfile:lines() do
        -- Only add files that end with .lua
        if file:match("%.lua$") then
            file = string.sub(file, #(dir) + 2)
            print(file)
            table.insert(files, file)
        end
    end

    pfile:close()
    return files
end

-- Function to require all Lua files in the given directory
local function require_lua_files(dir)
    local lua_files = get_lua_files(dir)

    for _, file in ipairs(lua_files) do
        -- Convert file path to require path (replace / or \ with . and remove .lua extension)
        local require_path = file:gsub("/", "."):gsub("\\", "."):gsub("%.lua$", "")
        
        -- Remove the initial directory from the path to make it relative
        require_path = require_path:gsub("^" .. dir:gsub("/", "."):gsub("\\", "."), "")
    
        print(require_path)
        -- Require the file
        require(require_path)
    end
end

local function source_lua_files()
    --[[
    local nixos_config_path = os.getenv("NIXOS_CONFIG_PATH")
    local lua_cfg_path = nixos_config_path .. "/modules/home/cli-apps/nvf/lua"
    get_lua_files(lua_cfg_path)
    require_lua_files(lua_cfg_path)
    ]]--

    require("test") 
    
    require("cmp")
end

source_lua_files()
]=]--



local function source_lua_files_in_directory(dir)
    local function source_files(path)
        for _, file in ipairs(vim.fn.readdir(path)) do
            local full_path = path .. '/' .. file
            if vim.fn.isdirectory(full_path) == 1 then
                -- Recursively source files in subdirectory
                source_files(full_path)
            elseif file:match('%.lua$') then
                -- Source the Lua file
                print(full_path)
                vim.cmd('luafile ' .. full_path)
            end
        end
    end

    source_files(dir)
end
   



local function source_lua_files()
    local nixos_config_path = os.getenv("NIXOS_CONFIG_PATH")
    local lua_cfg_path = nixos_config_path .. "/modules/home/cli-apps/nvf/lua"
    
    source_lua_files_in_directory(lua_cfg_path)
    
    print("sourced config")
end

-- source_lua_files()

--[[
wa | source $nixos_config_path/modules/home/cli-apps/nvf/lua/reload.lua

-- get config file
echo stdpath('config')
]]--


vim.g.mapleader = " "

print("loaded reload")
vim.keymap.set(
    'n', '<leader>sc', 
    source_lua_files
    -- { noremap = true, silent = true }
)



vim.keymap.set("n", "<leader>gl", "<cmd> Telescope find_files<CR>", {["desc"] = "Find files [Telescope]",["expr"] = false,["noremap"] = true,["nowait"] = false,["script"] = false,["silent"] = true,["unique"] = false})

vim.keymap.set(
    'n', '<leader>st', 
    function() print("test leader") end
    -- { noremap = true, silent = true }
)

vim.keymap.set(
    'n', 'ge', 
    function() print("test") end
    -- { noremap = true, silent = true }
)

