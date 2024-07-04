{
  pkgs,
  my_lib,
  inputs,
  lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
  ];

  config = {
    # TODO: is the tradeof worth it?
    #  default: 5.3 GB, mod: 6.7 GB
    # The default compression-level is (6) and takes too long on some machines (>30m).
    # 3 takes <2m
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

    # done by the imports
    /*
    users.users.root.initialHashedPassword = "";

    users.users.nixos = {
      isNormalUser = true;
      description = "nixos";

      extraGroups = ["networkmanager" "wheel"];

      initialHashedPassword = "";
    };

    */
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.upidapi = {
      isNormalUser = true;
      description = "upidapi";

      extraGroups = ["networkmanager" "wheel" "libvirtd"];
      hashedPassword = "$y$j9T$P.ANM.hAc1bqSR7fJWfkZ.$vUxY3KyPB65PR3uTBKwYCa7u6LvUquy47SeAPjgnjD9";

      # openssh.authorizedKeys.keys = with import ./../../other/ssh-keys.nix; [upidapi-nix-pc upidapi-nix-laptop];
    };

    modules.nixos = {
      suites.all = enable;

      # collides with the installer stuff
      hardware.network.enable = lib.mkForce false;
      system.security.openssh.enable = lib.mkForce false;
    };
  };
}
