{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.tofu.default;
in {
  # terraform code for homelab
  options.modules.nixos.homelab.tofu.default = mkEnableOpt "";

  config = mkIf cfg.enable {
    sops.secrets."tofu-cloudflare-token" = {};

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "tof" ''
        key_path=${config.sops.secrets."ddclient-cf-token".path}
        CLOUDFLARE_API_TOKEN=$(cat $key_path) tofu "$@"
      '')
      tofu
    ];
  };
}
