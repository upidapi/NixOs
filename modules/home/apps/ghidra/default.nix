{
  config,
  pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.ghidra;
in {
  options.modules.home.apps.ghidra =
    mkEnableOpt "Whether or not to enable ghidra";

  config = let
    # v = "11.1.2";
    # ghidra_dir = ".config/ghidra/ghidra_${v}_NIX";
    ghidra_dir = ".config/ghidra/${pkgs.ghidra.distroPrefix}";
  in
    mkIf cfg.enable {
      home.packages = with pkgs; [
        ghidra
      ];

      # maybe use this one instead
      # https://github.com/zackelia/ghidra-dark-theme
      # apple theme taken from here
      # https://github.com/lr-m/ghidra-themes

      # NOTE: for some dumb reson the config dir is based on
      #  the version so you have to update this each time ghidra
      #  updates

      home.file."${ghidra_dir}/themes/apple.theme".text = builtins.readFile ./apple.theme;

      # maybe disable the tips
      modules.home.standAloneFile."${ghidra_dir}/preferences" = {
        override = false;
        text = ''
          GhidraShowWhatsNew=false
          SHOW.HELP.NAVIGATION.AID=true
          SHOW_TIPS=true
          TIP_INDEX=0
          Theme=File\:${config.home.homeDirectory}/${ghidra_dir}/themes/apple.theme
          USER_AGREEMENT=ACCEPT
          ViewedProjects=
        '';
      };
    };
}
