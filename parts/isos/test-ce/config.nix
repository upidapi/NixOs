# an image made to be as minimal as possible, excluding
# almost everything to remove possible assumptions
# made for testing install scripts
{
  my_lib,
  inputs,
  self,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    "${self}/modules/nixos/misc/iso.nix"
  ];

  config = {
    # put the installer.sh script in place
    systemd.services.create_install_script = let
      file = pkgs.writers.writeBash "install_script" ''
        nix run \
          --extra-experimental-features "flakes nix-command" \
          github:upidapi/nixos#install
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
          name = "test-install";
        };

      nix = {
        cfg-path = "/persist/nixos";
      };

      os = {
        # technically not needed but really nice for debug
        networking = enable;
        boot = enable;
      };
    };
  };
}
