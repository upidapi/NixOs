-------------------
-- About lualine --
-------------------

-- create a component to show macro recording thingy
-- REF: https://github.com/Traap/nvim/blob/master/lua/traap/plugins/lualine.lua#L5
local function show_macro_recording()
    local recording_register = vim.fn.reg_recording()
    if recording_register == "" then
        return ""
    else
        return "recording @" .. recording_register
    end
end

vim.api.nvim_create_autocmd("RecordingEnter", {
    callback = function()
        require("lualine").refresh({
            place = { "statusline" },
        })
    end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = function()
        local timer = vim.loop.new_timer()
        timer:start(
            50,
            0,
            vim.schedule_wrap(function()
                require("lualine").refresh({
                    place = { "statusline" },
                })
            end)
        )
    end,
})


require("lualine").setup({
    options = {
        theme = "auto",
        globalstatus = true,
    },

    sections = {
        lualine_a = {
            'mode'
        },
        lualine_b = {
            'branch',
            'diff',
            'diagnostics'
        },
        lualine_c = {
            'filename'
        },

        -- midpoint

        lualine_x = {
            -- replaced by neovim
            -- https://github.com/neovim/neovim/blob/7a20f93a929abda22f979e92fd75b92e447d1e2a/src/nvim/option_vars.h#L269
            "%S", -- showcmd buffer
        },
        lualine_y = {
            show_macro_recording
        },
        lualine_z = {
            'location'
        }
    },
})


-- required for %S to work
-- https://github.com/nvim-lualine/lualine.nvim/issues/1129
vim.o.showcmdloc = "statusline"
vim.o.showcmd = true

-- hide the default "bar"
vim.opt.cmdheight = 0
