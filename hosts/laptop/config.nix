{
  # config,
  # pkgs,
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
  system.stateVersion = "23.11"; # Did you read the comment?

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    # make a cfg-editor group that makes it so that a user
    # can edit the config
    extraGroups = ["networkmanager" "wheel" "libvirtd"];
    initialPassword = "1";
    # packages = with pkgs; [
    #   # firefox
    # ];
  };

  # user.user.root.initialPassword = "1";

  modules.nixos = {
    host-name = "upidapi-nix-laptop";

    other = enable;

    home-tunnel = enable;

    cli-apps = {
      less = enable;
      keepass = enable;
    };

    apps = {
      steam = enable;
    };

    tools = {
      playerctl = enable;
    };

    security = {
      sudo-rs = enable;
    };

    system = {
      core = {
        fonts = enable;
        boot = enable;
        env = enable;
        locale = enable;
      };

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
    };

    desktop.sddm = enable;

    hardware = {
      # cpu.amd = enable;
      # gpu.nvidia = enable;

      bth = enable;
      sound = enable;
      network = enable;
      keyboard = enable;
      monitors = [
        {
          name = "eDP-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 0;
          y = 0;
          workspace = 2;
        }
      ];
    };
  };
}
