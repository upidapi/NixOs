-- https://github.com/m4xshen/smartcolumn.nvim
-- require("smartcolumn").setup({
--     colorcolumn = { "80", "100" },
--     custom_colorcolumn = {},
--     disabled_filetypes = {
--         "help",
--         "text",
--         "markdown",
--         "NvimTree",
--         "alpha"
--     }
-- }
-- )

local smartcolumn = {}

-- default
local config = {
    colorcolumn = "80",
    disabled_filetypes = { "help", "text", "markdown" },
    custom_colorcolumn = {},
    scope = "file",
    editorconfig = true,
}

local function should_show(buf, win, min_colorcolumn)
    local lines = {}

    if config.scope == "file" then
        lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true) -- file scope
    elseif config.scope == "line" then
        lines = vim.api.nvim_buf_get_lines(
            buf,
            vim.fn.line(".", win) - 1,
            vim.fn.line(".", win),
            true
        )
    elseif config.scope == "window" then
        lines = vim.api.nvim_buf_get_lines(
            buf,
            vim.fn.line("w0", win) - 1,
            vim.fn.line("w$", win),
            true
        )
    end

    local max_column = 0

    for _, line in pairs(lines) do
        local success, column_number = pcall(vim.fn.strdisplaywidth, line)

        if not success then
            return false
        end

        max_column = math.max(max_column, column_number)
    end

    return max_column > min_colorcolumn
end

local function colorcolumn_editorconfig(colorcolumns)
    return vim.b[0].editorconfig
            and vim.b[0].editorconfig.max_line_length ~= "off"
            and vim.b[0].editorconfig.max_line_length
        or colorcolumns
end

local function get_custom_colorcolumn(buf)
    local buf_filetype = vim.api.nvim_get_option_value("filetype", {
        buf = buf,
    })

    local colorcolumns

    if type(config.custom_colorcolumn) == "function" then
        colorcolumns = config.custom_colorcolumn()
    else
        colorcolumns = config.custom_colorcolumn[buf_filetype]
            or config.colorcolumn
    end

    if config.editorconfig then
        colorcolumns = colorcolumn_editorconfig(colorcolumns)
    end

    return colorcolumns
end

local function update(buf)
    local colorcolumns = get_custom_colorcolumn(buf)

    local min_colorcolumn = colorcolumns
    if type(colorcolumns) == "table" then
        min_colorcolumn = colorcolumns[1]
        for _, colorcolumn in pairs(colorcolumns) do
            min_colorcolumn = math.min(min_colorcolumn, colorcolumn)
        end
    end
    min_colorcolumn = tonumber(min_colorcolumn)

    -- local current_buf = vim.api.nvim_get_current_buf()
    local wins = vim.api.nvim_list_wins()

    for _, win in pairs(wins) do
        local b = vim.api.nvim_win_get_buf(win)
        if b ~= buf then
            goto continue
        end

        vim.wo[win].colorcolumn = ""

        if vim.tbl_contains(config.disabled_filetypes, buf) then
            require("lua.utils.logger").log("dis")
            goto continue
        end

        if not should_show(buf, win, min_colorcolumn) then
            goto continue
        end

        if type(colorcolumns) == "table" then
            vim.wo[win].colorcolumn = table.concat(colorcolumns, ",")
        else
            vim.wo[win].colorcolumn = colorcolumns
        end

        -- require("lua.utils.logger").log("test", color_col)

        ::continue::
    end
end

function smartcolumn.setup(user_config)
    user_config = user_config or {}

    for option, value in pairs(user_config) do
        config[option] = value
    end

    local augroup = vim.api.nvim_create_augroup("SmartColumn", {})

    local events
    if config.scope == "line" then
        events = { "BufEnter", "TextChanged", "InsertLeave", "WinScrolled", "CursorMoved", "CursorMovedI" }
    else
        events = { "BufEnter", "TextChanged", "InsertLeave", "WinScrolled" }
    end

    vim.api.nvim_create_autocmd(events, {
        group = augroup,
        callback = function(args)
            update(args.buf)
        end,
    })
end
smartcolumn.setup({
    colorcolumn = { "80", "100" },
    custom_colorcolumn = {},
    scope = "window",
    disabled_filetypes = {
        "help",
        "text",
        "markdown",
        "NvimTree",
        "alpha",
    },
})

return smartcolumn
