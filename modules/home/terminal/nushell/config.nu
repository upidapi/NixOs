let carapace_completer = {|spans|
  carapace $spans.0 nushell $spans | from json
}

$env.config = {
  show_banner: false,
  edit_mode: vi,
  use_kitty_protocol: true,

  completions: {
    # case-sensitive completions
    case_sensitive: false 

    # set to false to prevent auto-selecting completions
    quick: true       
    
    # set to false to prevent partial filling of the prompt
    partial: true

    # prefix or fuzzy
    algorithm: "fuzzy"

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

  shell_integration: {
    osc2: false,
    osc7: true,
    osc8: true,
    osc133: true,
    osc633: true,
    reset_application_mode: true,
  },

  history: {
    sync_on_enter: true,
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

$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "> " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "| " }
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
