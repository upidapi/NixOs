{
  #  config,
  # pkgs,
  # lib,
  # inputs,
  # inputs',
  # self,
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

    openssh.authorizedKeys.keys = [keys.users.admin];
  };

  users.users.root.hashedPassword = "$y$j9T$9xMPUcZ6FDsmUAHnIlyk80$8bJB3zlzCf3VsqAfpxaJ9qBhLiDq3syabSj1n/xUH41";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems.zfs = lib.mkForce false;

  modules.nixos = {
    suites.all = enable;

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      monitors = [
        {
          name = "eDP-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 0;
          y = 0;
          workspace = 1;
          primary = true;
        }
      ];
    };
  };
}
