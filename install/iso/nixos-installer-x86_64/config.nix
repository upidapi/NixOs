{
  pkgs,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    "${pkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${pkgs}/nixos/modules/installer/cd-dvd/channel.nix"
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

    # TODO: factor out this into some module

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.upidapi = {
      isNormalUser = true;
      description = "upidapi";

      extraGroups = ["networkmanager" "wheel" "libvirtd"];
      hashedPassword = "$y$j9T$EYMQdTmw82Nd2wnoDxrB10$OGquV37TGBUPTjhQAQ71xCMtmo3y0mnQiznUbME4UT3";

      # use the pub keys in each host instead
      # openssh.authorizedKeys.keys = with import ./../../other/ssh-keys.nix; [upidapi-nix-pc upidapi-nix-laptop];
    };

    users.users.root.hashedPassword = "$y$j9T$kV/aEFz0la0QtThvK5Ghp1$oxghtnjsA0mSXrM62uY99l7ijDIN5tIFynkKhNcEOP0";

    modules.nixos = {
      suites.all = enable; # TODO: dont enable everython

      hardware.monitors = [
        # disable
        # https://github.com/hyprwm/Hyprland/issues/5958
        # https://github.com/hyprwm/Hyprland/issues/6032
        {
          name = "Unknown-1";
          enabled = false;
          workspace = -1;
        }
        {
          name = "DVI-D-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = -1920;
          y = 0;
          primary = true;
          workspace = 1;
        }
        {
          name = "DP-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 0;
          y = 0;
          workspace = 2;
        }
        {
          name = "HDMI-A-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 1920;
          y = 0;
          workspace = 3;
        }
      ];
    };
  };
}
