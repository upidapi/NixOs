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
    isoImage.squashfsCompression = "zstd -Xcompression-level 3";

    nixpkgs = {
      hostPlatform =
        /*
        lib.mkDefault
        */
        "x86_64-linux";
      config.allowUnfree = true;
    };

    # its an iso so it doesnt have to be preserved
    # system.stateVersion = "23.11";

    # Enable the X11 windowing system.
    # services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    # services.xserver.displayManager.sddm.enable = true;
    # services.xserver.desktopManager.plasma5.enable = true;

    # done bu the imports
    /*

    users.users.root.initialHashedPassword = "";

    users.users.nixos = {
      isNormalUser = true;
      description = "nixos";

      extraGroups = ["networkmanager" "wheel"];

      initialHashedPassword = "";
    };
    */

    environment.systemPackages = [
      pkgs.git
    ];

    modules.nixos = {
      nix = {
        cfg-path = "/persist/nixos";

        cachix = enable;
        flakes = enable;
      };

      os = {
        boot = enable;

        environment = {
          fonts = enable;
          locale = enable;
          paths = enable;
          vars = enable;
        };

        misc = {
          console = enable;
        };
      };
    };
  };
}
