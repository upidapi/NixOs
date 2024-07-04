{
  pkgs,
  # my_lib,
  ...
}:
/*
      let
  inherit (my_lib.opt) enable;
in
*/
{
  /*
  imports = [
    "${pkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${pkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];
  */

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
  };
}
