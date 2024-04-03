{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.modules.nixos.users = mkOption {
    type = types.attrsOf (
      types.submodule {}
    );
  };

  # config = mkIf cfg.enable {
  #
  # };
}
