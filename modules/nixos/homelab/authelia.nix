{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.authelia;
in {
  options.modules.nixos.homelab.authelia = mkEnableOpt "authelia";

  # https://www.authelia.com/integration/proxies/caddy/#subdomain
  # REF: https://github.com/Stupremee/nix/blob/de5ce056514b91ecbb8fc8f5e71728402e14c747/modules/nixos/caddy/default.nix#L32
  # REF: https://codeberg.org/PopeRigby/config/src/commit/413e011bd63e93b93f92b20254b19b422188cab3/systems/x86_64-linux/haddock/services/auth/authelia.nix#L83
  config =
    mkIf cfg.enable {
    };
}
