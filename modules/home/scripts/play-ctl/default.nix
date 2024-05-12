{
  config,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.scripts.qs;
in {
  options.modules.home.scripts.qs =
    mkEnableOpt
    "Whether or not to add the qs command";

  config = mkIf cfg.enable {
    systemd.user.services.playctld = {
      description = "a daemon that keeps track of the media";
      serviceConfig.PassEnvironment = "DISPLAY";
      script = ''
        python3 {./play-ctl-daemon.py}
      '';
      wantedBy = ["multi-user.target"]; # starts after login
    };

    home.packages = [
      (
        pkgs.writers.writePython3Bin
        "playctl"
        {
          flakeIgnore = ["W291" "W293" "E501" "E303" "W503"];
        }
        (builtins.readFile ./play-ctl.py)
      )
    ];
  };
}
