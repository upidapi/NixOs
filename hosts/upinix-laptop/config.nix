{
  # config,
  pkgs,
  lib,
  # inputs,
  # inputs',
  self,
  # self',
  my_lib,
  keys,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  system.stateVersion = "23.11"; # Did you read the comment?

  # TODO: factor out this into some module

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    extraGroups = ["networkmanager" "wheel" "libvirtd"];
    hashedPassword = "$y$j9T$P.ANM.hAc1bqSR7fJWfkZ.$vUxY3KyPB65PR3uTBKwYCa7u6LvUquy47SeAPjgnjD9";

    openssh.authorizedKeys.keys = [keys.users.upidapi];
  };

  users.users.root.hashedPassword = "$y$j9T$9xMPUcZ6FDsmUAHnIlyk80$8bJB3zlzCf3VsqAfpxaJ9qBhLiDq3syabSj1n/xUH41";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems.zfs = lib.mkForce false;
    # fix issues with keyboard after suspend
    kernelParams = ["i8042.reset" "i8042.nomux" "i8042.nopnp" "i8042.noloo"];
  };

  # FIXME: enable when it works
  /*
  hardware = {
    tuxedo-keyboard = enable;
    tuxedo-rs = {
      enable = true;
      tailor-gui = enable;
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      tuxedo-keyboard = prev.tuxedo-keyboard.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            "${self}/parts/patches/tuxedo-keyboard.path"
          ];
      });
    })
  ];
  */

  modules.nixos = {
    suites.all = enable;

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      monitors = [
        {
          name = "desc:BOE 0x0C8E";

          width = 2560;
          height = 1600;
          refreshRate = 240;
          x = 0;
          y = 0;
          scale = 1.333333;

          workspace = 1;
          primary = true;
        }
      ];
    };
  };
}
