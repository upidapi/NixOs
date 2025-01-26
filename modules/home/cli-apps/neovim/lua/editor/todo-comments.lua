----- todo comments -----
-- https://github.com/folke/todo-comments.nvim
--
-- TodoQuickFix
-- commands, cn[ext], np[rev], cf[irst], cl[ast]

require("todo-comments").setup({
    highlight = {
        after = "fg",
        before = "",
        comments_only = true,
        keyword = "wide",
        max_line_len = 1000,
        multiline = true,
        multiline_pattern = "^ ",
        pattern = [[ (KEYWORDS):]], -- [[ <(KEYWORDS)(?:\/.[^\/]*)*:]]
    },
    search = {
        -- this is a custom option
        -- list of categories that will be shown on :TodoTelescope
        categories = {
            "EXPLORE",
            "FIX",
            "HACK",
            "PREF",
            "TODO",
            "WARN",
        },
        args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
        },
        command = "rg",
        pattern = [[ (KEYWORDS):]],
    },
    colors = {
        default = {
            "Identifier",
            "#7C3AED",
        },
        error = {
            "DiagnosticError",
            "ErrorMsg",
            "#DC2626",
        },
        hint = {
            "DiagnosticHint",
            "#10B981",
        },
        test = {
            "Identifier",
            "#FF00FF",
        },
        todo = {
            -- "DiagnosticInfo",
            "#2563EB",
        },
        warning = {
            "DiagnosticWarn",
            "WarningMg",
            "#FBBF24",
        },
    },
    guiStyle = {
        fg = "BOLD",
    },
    keywords = {
        EXPLORE = {
            alt = {
                "EXP",
            },
            color = "todo",
            icon = "󰍉",
        },
        FIX = {
            alt = {
                "BROKEN",
                "FIXME",
                "BUG",
                "FIXIT",
                "ISSUE",
            },
            color = "error",
            icon = " ",
        },
        HACK = {
            color = "warning",
            icon = " ",
        },
        NOTE = {
            alt = {
                "INFO",
            },
            color = "hint",
            icon = "󰍩 ",
        },
        PERF = {
            alt = {
                "OPTIM",
                "PERFORMANCE",
                "OPTIMIZE",
            },
            icon = "󰅒 ",
        },
        REF = {
            alt = {
                "FROM",
            },
            color = "hint",
            icon = " ",
        },
        TODO = {
            alt = {
                "todo",
            },
            color = "todo",
            icon = " ", -- "broken", should look like na-fa-check
        },
        WARN = {
            alt = {
                "WARNING",
                "XXX",
            },
            color = "warning",
            icon = " ",
        },
    },
    signs = false,
})

local default_cat = {
    "EXPLORE",
    "FIX",
    "HACK",
    "PERF",
    "TODO",
    "WARN",
    -- "NOTE"
    -- "REF"
}

-- local function dump(o)
--     if type(o) == 'table' then
--         local s = '{ '
--         for k, v in pairs(o) do
--             if type(k) ~= 'number' then k = '"' .. k .. '"' end
--             s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
--         end
--         return s .. '} '
--     else
--         -- return "\"" .. tostring(o) .. "\""
--         return "[[" .. tostring(o) .. "]]"
--     end
-- end

local config = require("todo-comments.config")
local options = config._options

local function keywords_to_aliases(keywords)
    -- get the names and aliases of the keywords in the
    -- categories included
    local search_words = {}
    for _, keyword in ipairs(keywords) do
        local names = {
            keyword,
            -- aliases
            table.unpack(options.keywords[keyword].alt or {}),
        }

        if names then
            for i = 1, #names do
                table.insert(search_words, names[i])
            end
        end
    end

    return search_words
end

local function aliases_to_keywords(aliases)
    local keywords = {}
    for _, alias in ipairs(aliases) do
        local keyword = config.keywords[alias]
        if not keyword then
            error("the alias " .. alias .. " not found")
        end

        table.insert(keywords, keyword)
    end
    return keywords
end

local function catagory_search(args)
    local search_words = keywords_to_aliases(
        aliases_to_keywords(
            next(args.fargs) == nil and default_cat
                or vim.split(args.fargs[1], " ")
        )
    )

    local cmd = "TodoTelescope keywords=" .. table.concat(search_words, ",")
    -- vim.fn.setreg("+", x)
    -- print(x)

    vim.cmd(cmd)

    -- vim.cmd(
    --     "TodoTelescope"
    -- )
end

vim.api.nvim_create_user_command("TodoTelescopeCat", catagory_search, {
    nargs = "?",
    complete = function(arglead)
        local matches = {}
        for alias, _ in pairs(config.keywords) do
            if string.sub(alias, 1, #arglead) == arglead then
                table.insert(matches, alias)
            end
        end
        return matches
    end,
})
