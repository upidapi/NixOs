local function add_files_to_quickfix(dir_path)
    local uv = vim.loop
    local files = {}

    -- List of extensions to match
    local extensions = {
        -- ".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs", ".json", ".css", ".html", ".vue"
        ".js",
        ".ts",
        ".nix",
        ".md",
        ".txt",
        ".lua",
    }

    -- Check if a filename has a matching extension
    local function has_valid_extension(filename)
        for _, ext in ipairs(extensions) do
            if filename:sub(-#ext) == ext then
                return true
            end
        end
        return false
    end

    -- Recursively scan directory for matching files
    local function scan_directory(path)
        local handle = uv.fs_scandir(path)
        if not handle then
            return
        end
        while true do
            local name, type = uv.fs_scandir_next(handle)
            if not name then
                break
            end
            local full_path = path .. "/" .. name
            if type == "file" and has_valid_extension(name) then
                table.insert(files, full_path)
            elseif type == "directory" then
                scan_directory(full_path)
            end
        end
    end

    -- Start scanning from the specified directory path
    scan_directory(dir_path)

    -- Add all found files to the quickfix list
    local qf_list = {}
    for _, file in ipairs(files) do
        table.insert(qf_list, { filename = file })
    end
    vim.fn.setqflist(qf_list, "r")

    -- Open quickfix list
    vim.cmd("copen")
end

-- Example usage: Replace with the directory path you want to scan
add_files_to_quickfix(vim.env.NIXOS_CONFIG_PATH)
