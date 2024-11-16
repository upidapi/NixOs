let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

# TODO: how to scroll terminal with keybinds

# TODO: change the completion colors

$env.config = {
  show_banner: false,
  edit_mode: vi,
  use_kitty_protocol: true,
    
  table: {
    # remove the left and right edges from tables
    mode: compact 
  }

  ls: {
    use_ls_colors: true # use the LS_COLORS environment variable to colorize output
    clickable_links: true # enable or disable clickable links. Your terminal has to support links.
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
} 

# just using $EDITOR doesnt work in nushell
alias e = nu -c $env.EDITOR

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
  
  # [$path (realpath $path)] | any {|p| {
  #    $p | path type | if $in != "symlink"       
  # }}
  #   
  #
  #  {return}
    
  # KISS 
  (realpath $path) | path type | if $in != "symlink" {
    echo "only symlinks to files supported"
    return
  }

  (realpath $path) | path type | if $in != "file" {
    echo "only symlinks to files supported"
    return
  }

  # might be some better way to do this
  run-external "cp" "--remove-destination" (readlink $path) $path  

  chown (whoami) $path 
  chmod +w $path
}

def store-edit [path: path] {
  unstore $path

  nu -c $env.TERMINAL $path
}
