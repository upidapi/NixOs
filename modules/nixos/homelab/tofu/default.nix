{
  config,
  lib,
  my_lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.tofu;
in {
  # terraform code for homelab
  options.modules.nixos.homelab.tofu = mkEnableOpt "";

  config = mkIf cfg.enable {
    sops.secrets."tofu-cloudflare-token" = {
      sopsFile = "${self}/secrets/infra.yaml";
    };

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "tof" ''
        key_path=${config.sops.secrets."ddclient-cf-token".path}
        CLOUDFLARE_API_TOKEN=$(cat $key_path) tofu "$@"
      '')
      opentofu
    ];
  };
}
