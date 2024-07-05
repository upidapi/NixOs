# A minimal config used as a intermediate step when installing my
# config. Provides a basic env for debugging and does a few things
# to make the full install quicker
# The most important thing is activating flakes since nixos-install
# can't really handle them well (in theory you can use --flake but
# it's buggy / doesn't work)
{
  pkgs,
  self,
  # my_lib,
  ...
}: let
  # inherit (my_lib.opt) enable;
  enable = {enable = true;};
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # just the nixos part since the bootstrap config doesnt use
    # home-manager
    "${self}/modules/nixos"
  ];

  # TODO: posisbly trick nix by doing _module.args.inputs
  #  to fake the inputs
  # or just pull the config out of the modules

  modules.nixos = {
    # cli-apps = {
    #   less = enable;
    # };
    host-name = "nixos-boostrap";

    hardware.network = enable;

    system = {
      core = {
        # fonts = enable;
        boot = enable;
        env = enable;
        locale = enable;
      };

      nix = {
        cfg-path = "/persist/nixos";

        cachix = enable;
        flakes = enable;
      };
    };
  };

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

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.git
  ];

  system.stateVersion = "23.11"; # Did you read the comment?

  systemd.services.custom-nixos-installer = {
    description = "installs my nixos config";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      profile=$(cat /persist/nixos/profile-name.txt) &&
      nixos-rebuild switch --flake "/persist/nixos#$profile" &&
      rm /persist/nixos/profile.txt &&
      chown -R root:wheel /persist/nixos &&
      chmod -R 770 /persist/nixos &&
      reboot
    '';
    wantedBy = ["multi-user.target"]; # starts after login
  };
}
