{
  pkgs,
  my_lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  config = {
    # iso things:
    # The default compression-level is (6) and takes too long on some machines (>30m). 3 takes <2m
    isoImage.squashfsCompression = "zstd -Xcompression-level 3";
    nixpkgs = {
      hostPlatform =
        /*
        lib.mkDefault
        */
        "x86_64-linux";
      config.allowUnfree = true;
    };

    system.stateVersion = "23.11"; # Did you read the comment?

    # Enable the X11 windowing system.
    # services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    # services.xserver.displayManager.sddm.enable = true;
    # services.xserver.desktopManager.plasma5.enable = true;

    users.users.root.initialPassword = "";

    users.users.nixos = {
      isNormalUser = true;
      description = "nixos";

      extraGroups = ["networkmanager" "wheel"];

      initialPassword = "";

      # packages = with pkgs; [
      #   firefox
      #   kate
      # ];
    };

    environment.systemPackages = [
      pkgs.git
    ];

    modules.nixos = {
      # cli-apps = {
      #   less = enable;
      # };

      other = enable;

      # home-tunnel = enable;

      cli-apps = {
        less = enable;
        keepass = enable;
      };

      apps = {
        steam = enable;
      };

      system = {
        core = {
          fonts = enable;
          boot = enable;
          env = enable;
          locale = enable;
        };

        nix = {
          cfg-path = "/persist/nixos";

          cachix = enable;
          flakes = enable;
          gc = enable;
          nix-index = enable;
          misc = enable;
        };

        misc = {
          impermanence = enable;
          noshell = enable;
          sops = enable;
        };

        security = {
          sudo-rs = enable;
          # openssh = enable;
        };
      };

      desktop = {
        sddm = enable;
        hyprland = enable;
      };

      hardware = {
        cpu.amd = enable;
        gpu.nvidia = enable;

        bth = enable;
        sound = enable;
        network = enable;
        keyboard = enable;
      };

      /*
      hardware.network = enable;

      system = {
        core = {
          # fonts = enable;
          boot = enable;
          env = enable;
          locale = enable;
        };

        nix = {
          cfg-path = "/persist/nixos";

          cachix = enable;
          flakes = enable;
        };
      };
      */
    };
  };
}
