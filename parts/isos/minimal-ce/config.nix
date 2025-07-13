{
  pkgs,
  my_lib,
  inputs,
  lib,
  config,
  # self,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    # "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"

    # "${self}/modules/nixos/misc/iso.nix"
  ];

  config = let
    install-script =
      pkgs.writeScriptBin "install-cfg"
      # bash
      ''
        nix run \
          --extra-experimental-features "flakes nix-command" \
          github:upidapi/nixos#install -- $@
      '';
  in {
    environment.systemPackages = [
      install-script
      pkgs.git
    ];

    # put the installer.sh script in place
    systemd.services.create_install_script = {
      description = "installs my nixos config";
      serviceConfig.PassEnvironment = "DISPLAY";
      script = lib.getExe install-script;
      wantedBy = ["multi-user.target"]; # starts after login
    };

    # you cant have this and networking.networkmanager at the same time
    # networking.wireless.enable = false;

    isoImage.edition = lib.mkImageMediaOverride "minimal-ce";

    image.baseName =
      lib.pipe [
        "nixos"
        config.isoImage.edition
        config.system.nixos.label
        # (self.shortRev or "${builtins.substring 0 8 self.lastModifiedDate}-d")
        pkgs.stdenv.hostPlatform.system
      ] [
        (lib.filter (x: x != ""))
        (lib.concatStringsSep "-")
        lib.mkForce
        # lib.traceVal
      ];

    modules.nixos = {
      # misc.iso =
      #   enable
      #   // {
      #     name = "min-install";
      #   };

      nix = {
        cfg-path = "/persist/nixos";

        cachix = enable;
        flakes = enable;
      };

      os = {
        primaryUser = "upidapi";
        adminUser = "upidapi";

        boot = enable;

        env = {
          fonts = enable;
          locale = enable;
          paths = enable;
          xdg = enable;
        };

        networking = {
          wifi = enable;
          iphone-tethering = enable;
        };

        misc = {
          console = enable;
        };
      };
    };
  };
}
