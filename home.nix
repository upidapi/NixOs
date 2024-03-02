{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./monitors.nix
    # ./nixvim.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "upidapi";
  home.homeDirectory = "/home/upidapi";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # used to formatt nix code
    inputs.alejandra.defaultPackage.${pkgs.system}
    # gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons

    (pkgs.writeShellScriptBin "regen-nixos" ''
      # todo find some way to find the location of the flake
      nixFlakeDir=/etc/nixos/


      # make sure is root
      if [ "$EUID" -ne 0 ]
        then echo "This requires root to run"
        exit
      fi

      # make sure that user has selected a profile
      # for example "deafult"
      if [ $# -eq 0 ]
        then echo "NixOs profile not supplied"
        exit
      fi

      # make sure that we have a commit msg
      # for example "firefox is now in dark mode"
      if [ $# -eq 1 ]
        then echo "Generation note / msg not supplied"
        exit
      fi

      # goto where the nix configs are
      pushd nixFlakeDir > /dev/null


      # formatt code
      echo "Formatting Files..."
      alejandra . || true


      # show git diff
      echo -e "\n\nFile Diff:"
      git diff


      # rebuild ignore everything except errors
      echo -e "\n\nRebuilding NixOS... (profile: $1)"
      # if this fails dont commit
      nixos-rebuild switch --flake ".#$1" || exit 1


      # comit changes
      echo -e "\n\nCommiting changes..."

      # -am := add all staged changes, and a msg for the commit
      gen=$(nixos-rebuild list-generations | grep current)
      git commit -am "$2 ($gen)"  # --author="upidapi <videw@icloud.com>"


      echo -e "\n\nPushing code to github..."
      # todo put this in sops
      pat="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"
      git push https://$pat@github.com/upidapi/NixOs.git main


      popd > /dev/null


      echo -e "\n\nSuccessfully applied nixos configuration changes"
    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/upidapi/etc/profile.d/hm-session-vars.sh
  #

  programs.git = {
    enable = true;
    userName = "upidapi";
    userEmail = "videw@icloud.com";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };

  /*
     programs.neovim.plugins = [
  pkgs.vimPlugins.nvim-tree-lua
    {
      plugin = pkgs.vimPlugins.vim-startify;
      config = "let g:startify_change_to_vcs_root = 0";
    }
  ];
  */

  programs.firefox = {
    enable = true;

    profiles.upidapi = {
      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        bitwarden
      ];
      settings = {
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage" = "https://start.duckduckgo.com";
        "dom.security.https_only_mode" = true;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  monitors = [
    {
      name = "DVI-D-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 0;
      y = 0;
      workspace = 1;
    }
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 1920;
      y = 0;
      primary = true;
      workspace = 2;
    }
    {
      name = "HDMI-A-2";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 3840;
      y = 0;
      workspace = 3;
    }
  ];

  # todo move this to a module
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # mouse binds
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # kbd binds
    bind =
      [
        # "$mod, Q, exec, kitty"
        "$mod, E, exec, alacritty"
        "$mod, R, exec, firefox"
        "$mod, C, killactive"
        "$mod, M, exit"
        # "$mod, F, exec, firefox"
        # ", Print, exec, grimblast copy area"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );

    # display conf
    monitor =
      map
      (
        m: let
          resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
          position = "${toString m.x}x${toString m.y}";
        in "${m.name},${
          if m.enabled
          then "${resolution},${position},1"
          else "disable"
        }"
      )
      (config.monitors);

    # layout
    input = {
      kb_layout = "se"; # swedish layout
    };
  };
}
