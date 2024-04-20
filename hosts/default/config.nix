{
  # config,
  pkgs,
  # lib,
  # inputs,
  # inputs',
  # self,
  # self',
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    # Include the results of the hardware scan.
    # inputs.home-manager.nixosModules.default
    ./hardware.nix
  ];

  # todo: put this somewhere else
  # this just makes the user own /persist/nixos
  systemd.tmpfiles.settings = {
    # i believe that that name is arbitrary (10-mypackage)
    "10-mypackage" = {
      "/persist/nixos" = {
        z = {
          group = "users";
          mode = "0755";
          user = "upidapi";
        };
      };
    };
  };

  # virtualisation
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.

  programs.zsh.enable = true;
  environment.pathsToLink = ["/share/zsh"];
  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    # make a cfg-editor group that makes it so that a user
    # can edit the config
    extraGroups = ["networkmanager" "wheel" "libvirtd"];
    shell = pkgs.zsh;
    initialPassword = "1";
    # packages = with pkgs; [
    #   # firefox
    # ];
  };

  # user.user.root.initialPassword = "1";

  modules.nixos = {
    host-name = "upidapi-nix-pc";

    nix = {
      cfg-path = "/persist/nixos";

      cachix = enable;
      flakes = enable;
      gc = enable;
    };

    other = {
      sops = enable;
      impermanence = enable;
    };

    cli-apps = {
      less = enable;
      # zsh = enable;
      keepass = enable;
    };

    apps = {
      # nushell = enable;
      steam = enable;
    };

    system = {
      fonts = enable;
      boot = enable;
      env = enable;
      locale = enable;
    };

    desktop.sddm = enable;

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      bth = enable;
      sound = enable;
      network = enable;
      keyboard = enable;
      monitors = [
        {
          name = "DVI-D-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = -1920;
          y = 0;
          primary = true;
          workspace = 1;
        }
        {
          name = "DP-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 0;
          y = 0;
          workspace = 2;
        }
        {
          name = "HDMI-A-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 1920;
          y = 0;
          workspace = 3;
        }
      ];
    };
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.11"; # Did you read the comment?
}
