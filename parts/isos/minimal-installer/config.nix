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
    "${self}/modules/nixos/misc/iso.nix"
  ];

  config = {
    environment.systemPackages = [
      pkgs.git
    ];

    # put the installer.sh script in place
    systemd.services.create_install_script = let
      file = pkgs.writers.writeBash "install_script" ''
        nix run \
          --extra-experimental-features "flakes nix-command" \
          github:upidapi/nixos#install -- $@
      '';
    in {
      description = "installs my nixos config";
      serviceConfig.PassEnvironment = "DISPLAY";
      script = ''
        cat ${file} > /home/nixos/install.sh

        chown nixos /home/nixos/install.sh
        chmod +x /home/nixos/install.sh
      '';
      wantedBy = ["multi-user.target"]; # starts after login
    };

    # you cant have this and networking.networkmanager at the same time
    networking.wireless.enable = false;

    modules.nixos = {
      misc.iso =
        enable
        // {
          name = "min-install";
        };

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
