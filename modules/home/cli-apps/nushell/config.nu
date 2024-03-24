let carapace_completer = {|spans|
  carapace $spans.0 nushell $spans | from json
}

$env.config = {
  show_banner: false,
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
} 

$env.PATH = (
  $env.PATH | 
  split row (char esep) |
  prepend /home/myuser/.apps |
  append /usr/bin/env
)
