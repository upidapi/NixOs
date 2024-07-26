{
  pkgs,
  my_lib,
  inputs,
  self,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    # TODO:remove "-no-zfs"
    #  tuxedo required 6.10 (latest kernel)
    #  zfs takes a while to support the latest kernel
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
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
    # hardware.tuxedo-keyboard = enable;

    environment.systemPackages = [
      pkgs.git
    ];

    # put the installer.sh script in place
    systemd.services.create_install_script = let
      file = pkgs.writeText "install_script" (
        builtins.readFile "${self}/parts/install/install.sh"
      );
      file_flake = pkgs.writeText "install_script_flake" (
        builtins.readFile "${self}/parts/install/install_flake.sh"
      );
    in {
      description = "installs my nixos config";
      serviceConfig.PassEnvironment = "DISPLAY";
      script = ''
        cat ${file} > /home/nixos/install.sh
        cat ${file_flake} > /home/nixos/install_flake.sh

        chown nixos /home/nixos/install.sh
        chown nixos /home/nixos/install_flake.sh
      '';
      wantedBy = ["multi-user.target"]; # starts after login
    };

    # you cant have this and networking.networkmanager at the same time
    networking.wireless.enable = false;

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

        networking = enable;

        misc = {
          console = enable;
        };
      };
    };
  };
}
