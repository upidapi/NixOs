{
  my_lib,
  keys,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) enable disable;
in {
  imports = [
    ./suspend-keyboard-fix.nix
  ];

  system.stateVersion = "23.11";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems.zfs = lib.mkForce false;
  };

  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "adbusers"
    ];
    hashedPassword = "$y$j9T$P.ANM.hAc1bqSR7fJWfkZ.$vUxY3KyPB65PR3uTBKwYCa7u6LvUquy47SeAPjgnjD9";

    openssh.authorizedKeys.keys = [keys.users.upidapi];
  };

  users.users.root.hashedPassword = "$y$j9T$9xMPUcZ6FDsmUAHnIlyk80$8bJB3zlzCf3VsqAfpxaJ9qBhLiDq3syabSj1n/xUH41";

  hardware = {
    tuxedo-drivers = enable;
    # tuxedo-rs = {
    #   enable = true;
    #   tailor-gui = enable;
    # };
  };

  modules.nixos = {
    suites.all = enable;

    os.services.syncthing = disable;

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      monitors.monitors = {
        "desc:BOE 0x0C8E" = {
          width = 2560;
          height = 1600;
          refreshRate = 240;
          x = 0;
          y = 0;
          scale = 1.333333;

          workspace = 1;
          primary = true;
        };
      };
    };
  };
}
