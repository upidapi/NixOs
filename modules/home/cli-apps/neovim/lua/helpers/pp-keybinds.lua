local function pretty_print_keymaps_to_file()
    local modes = { "n", "i", "v", "x", "c", "s", "o", "t" }
    local file = io.open("keymaps.txt", "w")

    for _, mode in ipairs(modes) do
        file:write("Mode: " .. mode .. "\n")
        local maps = vim.api.nvim_get_keymap(mode)
        for _, map in ipairs(maps) do
            file:write(string.format("  %s -> %s\n", map.lhs, map.rhs or ""))
        end
        file:write("\n")
    end

    file:close()
end

pretty_print_keymaps_to_file()
