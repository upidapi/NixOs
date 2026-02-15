{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enable;
  cfg = config.modules.nixos.misc.programs.steam;
in {
  options.modules.nixos.misc.programs.steam = mkEnableOpt "Whether or not to enable Steam.";

  # NOTE: steam.enable also enables proton
  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-unwrapped"
        "steam-original"
        "steam-run"
      ];
    programs = {
      gamescope = enable;

      steam = {
        enable = true;
        remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
        #extraPackages = with pkgs; [
        #  steamcmd
        #];
        extraCompatPackages = [
          pkgs.proton-ge-bin
        ];

        gamescopeSession.enable = true;
      };

      gamemode = {
        enable = true;
        settings = {
          general = {
            inhibit_screensaver = 0;
            renice = 10;
          };
          # custom = {
          #   start = "${heyBin} hook gamemode --on";
          #   end = "${heyBin} hook gamemode --off";
          # };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      pkgs.protontricks

      # currently causes wine recompile, not fun
      # (wineWowPackages.full.override {
      #   wineRelease = "staging";
      #   mingwSupport = true;
      # })
      # winetricks

      # can change install dir at ./.local/share/lutris/system.yml
      # system:
      #   game_path: /home/upidapi/Games/lutris
      (lutris.override {
        extraPkgs = pkgs: [
          # List package dependencies here
          # This recompiles wine, which is really slow (30m+)
          # if not relly needed ill keep them commented out
          # wineWowPackages.stable
          # winetricks
        ];
      })
    ];

    # environment.systemPackages = [
    # ];
    #
    # programs = {
    #
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
