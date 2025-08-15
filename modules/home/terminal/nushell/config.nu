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


export extern "pastebin" [
  --never(-n) # Disable expiry (never expire).
  --url(-u): string # URL to connect to."
  --days(-d): int # Set days before expiry, defaults to 30.
  --pass(-p): string # Decryption password.
  --help
]

# some completions are only available through a bridge
# eg. tailscale
# https://carapace-sh.github.io/carapac-bin/setup.html#nushell
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

# $env.STARSHIP_SHELL = "bash"

let zoxide_completer = {|spans|
    $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
}

let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | $"value(char tab)description(char newline)" + $in
    | from tsv --flexible --no-infer
}

let my_zoxide_completer = {|spans|
  do $fish_completer ($spans | update 0 "cd")
}

let carapace_completer = {|spans|
  # carapace doesn't give completions if you don't give it any additional
  # # args
  # mut spans = $spans
  # if ($spans | is-empty) {
  #   $spans = [""]
  # }

  carapace $spans.0 nushell ...$spans | from json
    # remove ERR(ors)
    | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
    # sort by color
    | sort-by {
        let fg = $in.style?.fg? | default ""
        let attr = $in.style?.attr? | default ""

        # the ~ there to make "empty" results appear at the end
        $"($fg)~($attr)"
    }
}

let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -o 0.expansion
    mut spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        # carapace completions are incorrect for nu
        # (i don't think that is the case)
        # nu => $fish_completer
        # fish completes commits and branch names in a nicer way
        # but has no colors :(
        git => $fish_completer
        # carapace doesn't have completions for asdf
        asdf => $fish_completer
        __zoxide_z | __zoxide_zi => $my_zoxide_completer
        # use zoxide completions for zoxide commands
        # __zoxide_z | __zoxide_zi => $zoxide_completer
        _ => $carapace_completer
    } | do $in $spans
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
      completer: $external_completer # check 'carapace_completer'
    }
  }

  cursor_shape: {
    vi_insert: line
    vi_normal: block
    # emacs: line
  }

  history: {
    max_size: 100000 # Session has to be reloaded for this to take effect
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
      # search is done on the text written after activating the menu
      only_buffer_difference: false
      # marker: "| "
      marker: ""
      # indicator that appears with the menu is active
      type: {
        # type of menu
        layout: columnar
        # number of columns where the options are displayed
        columns: 4
        # optional value. if missing all the screen width is used to calculate column width
        col_width: 20
        # padding between columns
        col_padding: 2
      }

      style: {
        # the style
        text: {
          fg: $colors.shape_garbage.fg
          attr: n
        }

        # the style for description
        description_text: {
           fg: $colors.leading_trailing_space_bg
           attr: n
        }

        # the style for selected option
        selected_text: {
          fg: black # $colors.separator
          bg: $colors.shape_garbage.fg
          attr: b
        }

        match_text: {
          # fg: u
          attr: u
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
