{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.misc.dotnet;
in {
  options.modules.nixos.misc.dotnet = mkEnableOpt "enable some dotnet things";

  config = mkIf cfg.enable {
    environment = let
      dotnet-sdk = with pkgs.dotnetCorePackages;
        combinePackages [sdk_9_0 sdk_8_0];
      dotnetRoot = "${dotnet-sdk}/share/dotnet";
    in {
      etc = {
        "dotnet/install_location".text = dotnetRoot;
      };

      systemPackages = [
        dotnet-sdk
      ];
    };
  };
}
