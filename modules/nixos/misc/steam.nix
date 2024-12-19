{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.nixos.misc.steam;
in {
  options.modules.nixos.misc.steam = mkEnableOpt "Whether or not to enable Steam.";

  # NOTE: steam.enable also enables proton
  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-unwrapped"
        "steam-original"
        "steam-run"
      ];
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
      #extraPackages = with pkgs; [
      #  steamcmd
      #];
    };

    # environment.systemPackages = [
    #   pkgs.protontricks
    # ];
    #
    # programs = {
    #   gamescope = enable;
    #
    #   #   gamemode = {
    #   #     enable = true;
    #   #     settings = {
    #   #       general = {
    #   #         inhibit_screensaver = 0;
    #   #         renice = 10;
    #   #       };
    #   #       custom = {
    #   #         start = "${heyBin} hook gamemode --on";
    #   #         end = "${heyBin} hook gamemode --off";
    #   #       };
    #   #     };
    #   #   };
    #   # };
    #
    #   steam = {
    #     enable = true;
    #
    #     # Open ports in the firewall for Steam Remote Play
    #     remotePlay.openFirewall = true;
    #
    #     # Open ports in the firewall for Source Dedicated Server
    #     dedicatedServer.openFirewall = true;
    #
    #     extraCompatPackages = [
    #       pkgs.proton-ge-bin
    #     ];
    #   };
    # };
  };
}
