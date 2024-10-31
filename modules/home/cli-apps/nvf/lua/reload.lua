vim.g.mapleader = " "


--[[
-- source manually
lua package.path = "/persist/nixos/modules/home/cli-apps/nvf/?.lua;" .. package.path; vim.cmd("luafile /persist/nixos/modules/home/cli-apps/nvf/lua/init.lua"); print("manuall source")

-- copy to a reg
lua vim.fn.setreg('a', vim.api.nvim_exec("nmap", true))
]] --
local function hotload_config()
    local nixos_config_path = os.getenv("NIXOS_CONFIG_PATH")
    local modules_path = nixos_config_path .. "/modules/home/cli-apps/nvf"

    -- add config to path if required
    local add_to_path = modules_path .. "/?.lua"
    if not string.match(package.path, add_to_path) then
        package.path = add_to_path .. ";" .. package.path
    end

    vim.cmd('wa') -- save

    -- force reload
    -- package.loaded["lua.init"] = nil
    -- require("lua.init")

    vim.cmd('luafile ' .. modules_path .. '/lua/init.lua')

    print("sourced config")
end

vim.keymap.set(
    'n', '<leader>rc',
    hotload_config
-- { noremap = true }
)
