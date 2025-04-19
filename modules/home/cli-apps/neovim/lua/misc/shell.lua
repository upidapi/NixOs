-- REF: https://www.kiils.dk/en/blog/2024-06-22-using-nushell-in-neovim/
--
-- better nu support in nvim
-- https://www.kiils.dk/en/blog/2024-06-22-using-nushell-in-neovim/
local posix_shell_options = {
    shellcmdflag = "-c",
    shellpipe = "2>&1 | tee",
    shellquote = "",
    shellredir = ">%s 2>&1",
    shelltemp = true,
    shellxescape = "",
    shellxquote = "",
}

local nu_shell_options = {
    shellcmdflag = "--login --stdin --no-newline -c",
    shellpipe = "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record",
    shellquote = "",
    shellredir = "out+err> %s",
    shelltemp = false,
    shellxescape = "",
    shellxquote = "",
}

local function set_options(options)
    for k, v in pairs(options) do
        vim.opt[k] = v
    end
end

-- local function apply_shell_options()
--     -- check if the shell ends with "nu"
--     if vim.opt.shell:get():match("nu$") ~= nil then
--         set_options(nu_shell_options)
--     else
--         set_options(posix_shell_options)
--     end
-- end
--
-- apply_shell_options()
--
-- -- listen for changes to the shell option
-- vim.api.nvim_create_autocmd("OptionSet", {
--     pattern = "shell",
--     callback = function()
--         apply_shell_options()
--     end,
-- })

-- i use noshell so that detection doesnt work
set_options(nu_shell_options)
