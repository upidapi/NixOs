local telescope = require('telescope')
telescope.setup({
	defaults = {
		color_devicons = true,
		entry_prefix = "  ",
		file_ignore_patterns = {
			"node_modules",
			".git/",
			"dist/",
			"build/",
			"target/",
			"result/"
		},
		initial_mode = "insert",
		layout_config = {
			height = 0.800000,
			horizontal = {
				preview_width = 0.550000,
				prompt_position = "top",
				results_width = 0.800000
			},
			preview_cutoff = 120,
			vertical = {
				mirror = false
			},
			width = 0.800000
		},
		layout_strategy = "horizontal",
		path_display = {
			"absolute"
		},
		pickers = {
			find_command = {
				"fd"
			}
		},
		prompt_prefix = "     ",
		selection_caret = "  ",
		selection_strategy = "reset",
		set_env = {
			COLORTERM = "truecolor"
		},
		sorting_strategy = "ascending",
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
			"--no-ignore"
		},
		winblend = 0
	}
})
