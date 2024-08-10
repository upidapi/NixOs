# the "full-installer" should probably be a recovery thing
# or an iso for servers
{
  my_lib,
  inputs,
  lib,
  self,
  keys,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    "${self}/modules/nixos/misc/iso.nix"
  ];

  config = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.upidapi = {
      isNormalUser = true;
      description = "upidapi";

      extraGroups = ["networkmanager" "wheel" "libvirtd"];
      hashedPassword = "$y$j9T$P.ANM.hAc1bqSR7fJWfkZ.$vUxY3KyPB65PR3uTBKwYCa7u6LvUquy47SeAPjgnjD9";

      openssh.authorizedKeys.keys = [keys.users.upidapi];
    };

    modules.nixos = {
      suites.all = enable;

      misc.iso =
        enable
        // {
          name = "full-install";
        };

      # collides with the installer stuff
      os.networking = {
        enable = lib.mkForce false; # TODO: only disable networkmaanger
        openssh.enable = lib.mkForce false;
      };
    };
  };
}
