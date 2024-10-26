require('tokyonight').setup {
  transparent = false;
}
vim.cmd[[colorscheme tokyonight-night]]


-----------------
-- About noice --
-----------------
require("noice").setup({
    routes = {{
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
    }},
})


----- neo-tree -----
-- https://github.com/nvim-neo-tree/neo-tree.nvim 
-- TODO: config neo-tree
require("neo-tree").setup({
	add_blank_line_at_top = false,
	auto_clean_after_session_restore = false,
	default_source = "filesystem",
	enable_cursor_hijack = false,
	enable_diagnostics = true,
	enable_git_status = true,
	enable_modified_markers = true,
	enable_opened_markers = true,
	enable_refresh_on_write = true,
	git_status_async = false,
	hide_root_node = false,
	log_level = "info",
	log_to_file = false,
	open_files_do_not_replace_types = {
		"terminal",
		"Trouble",
		"qf",
		"edgy"
	},
	open_files_in_last_window = true,
	retain_hidden_root_indent = false,
	window = {
		width = 30
	}
})


----- smart column ------
-- https://github.com/m4xshen/smartcolumn.nvim
require("smartcolumn").setup({
    colorcolumn = {"80","100"},
    custom_colorcolumn = {};
    disabled_filetypes = {
        "help",
        "text",
        "markdown",
        "NvimTree",
        "alpha"
    }
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


---- colorizer ----
-- https://github.com/norcalli/nvim-colorizer.lua
require('colorizer').setup({
    -- for all filetypes
    -- filetypes = {},

    -- i don't think this is a option
    -- user_default_options = {}
})
-- NOTE: ccc breaks nixd :)


----- nvim ufo ------
local ufo = require('ufo')
ufo.setup()

vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds)
vim.keymap.set('n', 'zm', ufo.closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)


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
