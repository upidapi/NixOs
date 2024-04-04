{
  lib,
  my_lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.hardware.keyboard;
in {
  options.modules.nixos.hardware.keyboard =
    mkEnableOpt "enables sound for the system";

  config = mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = ["*"];
        settings = {
          # https://github.com/NixOS/nixpkgs/issues/236622
          main = {
            capslock = "escape"; # f caps lock
          };
          shift = {
            "¤" = "$";
          };
          altgr = {
            "$" = "¤";
          };
          "capslock+shift" = {
            "7" = "{";
            "8" = "[";
            "9" = "]";
            "0" = "}";
            "+" = "\\";
            "¨" = "~";
            # "´" = "";
          };
        };
      };
    };
  };
}
