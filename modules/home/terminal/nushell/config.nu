let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

let colors = $env.config.color_config

$env.config = {
  show_banner: false,
  edit_mode: vi,
  use_kitty_protocol: true,
    
  table: {
    # remove the left and right edges from tables
    mode: compact 
  }

  ls: {
    # use the LS_COLORS environment variable to colorize output
    use_ls_colors: true 
    # enable or disable clickable links. Your terminal has to support links.
    clickable_links: true 
  }

  completions: {
    # case-sensitive completions
    case_sensitive: false 

    # set to false to prevent auto-selecting completions
    quick: true       
    
    # set to false to prevent partial filling of the prompt
    partial: true

    # prefix or fuzzy
    # algorithm: "fuzzy"
    algorithm: "prefix"

    external: {
      # set to false to prevent nushell looking into 
      # $env.PATH to find more suggestions
      enable: true 
    
      # set to lower can improve completion performance at 
      # the cost of omitting some options
      max_results: 100 
      completer: $carapace_completer # check 'carapace_completer' 
    }
  }

  cursor_shape: {
    vi_insert: line 
    vi_normal: block
    # emacs: line
  }

  history: {
    max_size: 10000 # Session has to be reloaded for this to take effect
    sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
    file_format: "plaintext" # "sqlite" or "plaintext"
  }

  shell_integration: {
    osc2: false,
    osc7: true,
    osc8: true,
    osc133: true,
    osc633: true,
    reset_application_mode: true,
  },

  menus: [
    {
      name: completion_menu
      # Search is done on the text written after activating the menu
      only_buffer_difference: false 
      # marker: "| "
      marker: ""
      # Indicator that appears with the menu is active
      type: {
        # Type of menu
        layout: columnar          
        # Number of columns where the options are displayed
        columns: 4                
        # Optional value. If missing all the screen width is used to calculate column width
        col_width: 20             
        # Padding between columns
        col_padding: 2            
      }

      style: {
        # The style
        text: {
          fg: $colors.shape_garbage.fg 
          attr: n
        }

        # The style for description
        description_text: {
           fg: $colors.leading_trailing_space_bg      
           attr: n
        }

        # The style for selected option
        selected_text: {
          fg: black # $colors.separator
          bg: $colors.shape_garbage.fg        
          attr: b
        }

        match_text: {
            fg: u
            attr: b
        }

        selected_match_text: {
          fg: blue
          attr: rb
        }
      }
    }
    # {
    #   name: history_menu
    #   only_buffer_difference: true
    #   marker: "? "
    #   type: {
    #     layout: list
    #     page_size: 10
    #   }
    #   style: {
    #     text: $colors.shape_garbage.fg 
    #     selected_text: {attr: r}
    #     description_text: $colors.leading_trailing_space_bg
    #
    #     # text: red
    #     # selected_text: purple
    #     # description_text: blue
    #   }
    #   source: { |buffer, position|
    #     scope variables
    #     | where name =~ $buffer
    #     | sort-by name
    #     | each { |row| {value: $row.name description: $row.type} }
    #   }
    # }
  ]
} 

# just using $EDITOR doesnt work in nushell
def e [path: path] {
    nu -c $"($env.EDITOR) ($path)"
}
# alias e = nu -c $env.EDITOR

# $env.PATH = (
#   $env.PATH | 
#   split row (char esep) |
#   prepend /home/myuser/.apps |
#   append /usr/bin/env
# )


# $env.PROMPT_COMMAND = { || create_left_prompt }
# $env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }

# handled by starship
# $env.PROMPT_INDICATOR = {|| "> " }
# $env.PROMPT_INDICATOR_VI_INSERT = {|| "> " }
# $env.PROMPT_INDICATOR_VI_NORMAL = {|| "| " }
$env.PROMPT_INDICATOR = {|| "" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }

$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

$env.KITTY_SHELL_INTEGRATION = "enabled"


def cdmk [path: path] {
  mkdir $path
  cd $path
}

# Takes a symlink to the store and unlinks it so that the
# file (or dir) it pointed to is placed there insted
def unstore [path: path] {
  let real_path = realpath $path 

  $path | path type | if $in != "symlink" {
    echo "only symlinks are supported"
    return
  }

  rm $path
  cp -r $real_path $path

  chown (whoami) $path 
  chmod +w $path
}

def store-edit [path: path] {
  unstore $path

  e $path
}
