require('tokyonight').setup {
  transparent = false;
}
vim.cmd[[colorscheme tokyonight-night]]


-----------------
-- About noice --
-----------------
require("noice").setup({
    routes = {
        {
            filter = {
                event = "msg_show",
                any = {
                    { find = "%d+L, %d+B" },
                    { find = "; after #%d+" },
                    { find = "; before #%d+" },
                    { find = "%d fewer lines" },
                    { find = "%d more lines" },
                },
            },
            opts = { skip = true },
        },
    },
})


-------------------
-- About lualine --
-------------------
require("lualine").setup({
    options = {
        theme = "auto",
        globalstatus = true,
    },
})

----------------------
-- About bufferline --
----------------------
require("bufferline").setup({
  options = {
    -- mode = 'tabs',
    numbers = 'none',
    close_command = 'bdelete! %d',
    right_mouse_command = '',
    left_mouse_command = 'buffer %d',
    middle_mouse_command = 'bdelete! %d',

    indicator = {
      -- icon = ' ', -- '▎',
      -- style = "icon",
      style = "none",
    },

    left_trunc_marker = '…',
    right_trunc_marker = '…',

    buffer_close_icon = '󰅖',
    modified_icon = '● ',
    close_icon = ' ',

    -- reserve space for neo-tree
    offsets = {{
      filetype = "neo-tree",
      -- text = vim.fn.getcwd,
      -- text_align = "left"
      text = "File Explorer",
      text_align = "center",
    }},

    color_icons = true,

    persist_buffer_sort = true,
    -- separator_style = "thin",
    -- enforce_regular_tabs = true,
    always_show_bufferline = true,
    sort_by = 'id',
  },
}) 


----- todo commens -----
-- https://github.com/folke/todo-comments.nvim
-- TODO: add bind for TodoQuickFix
--  bind <leader>ft to TodoTelescope
require('todo-comments').setup({
    colors = {
        default = {
            "Identifier",
            "#7C3AED"
        },
        error = {
            "DiagnosticError",
            "ErrorMsg",
            "#DC2626"
        },
        hint = {
            "DiagnosticHint",
            "#10B981"
        },
        test = {
            "Identifier",
            "#FF00FF"
        },
        todo = {
            "DiagnosticInfo",
            "#2563EB"
        },
        warning = {
            "DiagnosticWarn",
            "WarningMsg",
            "#FBBF24"
        }
    },
    guiStyle = {
        fg = "BOLD"
    },
    highlight = {
        after = "fg",
        before = "",
        commentsOnly = true,
        keyword = "wide",
        maxLineLen = 1000,
        multiline = true,
        multilinePattern = "^ ",
        pattern = ".*<(KEYWORDS)(\\([^\\)]*\\))?:"
    },
    keywords = {
        EXPLORE = {
            alt = {
                "EXP"
            },
            color = "#2563EB",
            icon = "󰍉"
        },
        FIX = {
            alt = {
                "FIXME",
                "BUG",
                "FIXIT",
                "ISSUE"
            },
            color = "error",
            icon = " "
        },
        HACK = {
            color = "warning",
            icon = " "
        },
        NOTE = {
            alt = {
                "INFO"
            },
            color = "hint",
            icon = "󰍩 "
        },
        PERF = {
            alt = {
                "OPTIM",
                "PERFORMANCE",
                "OPTIMIZE"
            },
            icon = "󰅒 "
        },
        REF = {
            color = "hint",
            icon = " "
        },
        TODO = {
            alt = {
                "todo"
            },
            color = "#2563EB",
            icon = " "
        },
        WARN = {
            alt = {
                "WARNING",
                "XXX"
            },
            color = "warning",
            icon = " "
        }
    },
    search = {
        args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column"
        },
        command = "/nix/store/jpylriswiywbbs2dw5x8v5db6jc25nj0-ripgrep-14.1.1/bin/rg",
        pattern = "\\b(KEYWORDS)(\\([^\\)]*\\))?:"
    },
    signs = false
})
