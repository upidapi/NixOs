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

        -- Require the file
        require(require_path)
    end
end


-- Usage example: recursively require all Lua files in "my_directory"
require_lua_files("my_directory")

vim.keymap.set('n', '<leader>sc', 
    function()
        local nixos_config_path = os.getenv("NIXOS_CONFIG_PATH")
        require_lua_files(nixos_config_path)
    end, 
    { noremap = true, silent = true }
)
