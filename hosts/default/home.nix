{
  pkgs,
  inputs,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
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
  # home.packages = [
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

  # gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons
  # ];

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

  home.packages = with pkgs; [
    # used to formatt nix code
    inputs.alejandra.defaultPackage.${pkgs.system}

    htop
    # maybe btop
  ];

  modules.home = {
    system = {
      # users.users.upidapi.shell = pkgs.zsh;
    };

    apps = {
      alacritty = enable;
      bitwarden = enable;
      discord = enable;
      firefox = enable;
      r2modman = enable;
    };

    cli-apps = {
      nixvim = enable;
      # nushell = enable;
      wine = enable;
      git = enable;
    };

    core = {
      persist = enable;
    };

    desktop = {
      wayland = enable;
      hyprland = enable;
      addons = {
        swww = enable;
        dunst = enable;
        gtk = enable;
        rofi = enable;
        waybar = enable;
      };
    };

    scripts = {
      regen-nixos = enable;
      cn-bth = enable;
      qs = enable;
    };
  };
}
