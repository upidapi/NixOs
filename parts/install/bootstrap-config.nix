# A minimal config used as a intermediate step when installing my
# config. Provides a basic env for debugging and does a few things
# to make the full install quicker
# The most important thing is activating flakes since nixos-install
# can't really handle them well (in theory you can use --flake but
# it's buggy / doesn't work)
{
  pkgs,
  # self,
  # my_lib,
  lib,
  ...
}:
/*
      let
  # inherit (my_lib.opt) enable;
  enable = {enable = true;};
in
*/
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    # just the nixos part since the bootstrap config doesnt use
    # home-manager
    # "${self}/modules/nixos"
  ];

  # posisbly use the module system, but then you have to copy it and
  # trick nix by doing _module.args.inputs to fake the inputs

  nix.settings = {
    # flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # build cache servers
    substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://cache.nixos.org/"
      "https://hyprland.cachix.org"
      "https://devenv.cachix.org"
    ];

    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  # Bootloader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems.zfs = lib.mkForce false;
  };

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "se";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  /*
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
  */

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
      profile=$(cat /persist/profile-name.txt) &&
      rm /persist/profile.txt &&

      # set the correct perms, otherwise git gets angry :(
      chown -R root:wheel /persist/nixos &&
      chmod -R 770 /persist/nixos &&

      # git config --global --add safe.directory /persist/nixos/.git &&

      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch \\
        --flake "/persist/nixos#$profile" &&

      reboot
    '';
    wantedBy = ["multi-user.target"]; # starts after login
  };
}
