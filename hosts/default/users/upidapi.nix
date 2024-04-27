{
  pkgs,
  inputs,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  # Dont change this unless you reinsall from scratch.
  home.stateVersion = "23.11"; # Read comment

  home.packages = with pkgs; [
    # used to formatt nix code
    inputs.alejandra.defaultPackage.${pkgs.system}

    # coding
    python3

    # you cant have both?
    clang
    # gcc

    cargo
    rustc

    # other
    htop
    ripgrep

    # stats about code, logical lines, comments, etc
    scc

    # maybe btop
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  modules.home = {
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
      zsh = {
        enable = true;
        set-shell = true;
      };
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
      # regen-nixos = enable;
      cn-bth = enable;
      qs = enable;
    };
  };
}
