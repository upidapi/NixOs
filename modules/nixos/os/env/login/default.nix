{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) types;
  inherit (mlib.opt) mkOpt;
  cfg = config.modules.nixos.os.env.login;
in {
  imports = [
    ./greetd.nix
    ./sddm.nix
  ];

  options.modules.nixos.os.env.login = {
    autoLogin = mkOpt types.bool false "enable auto login";
    command =
      mkOpt types.str null
      "the command run after login, sould probably start some type of DE";
  };

  config = {
    assertions = [
      {
        assertion = !cfg.autoLogin || (cfg.autoLogin && cfg.command != null);
        message = ".login.autoLogin requires .login.command to be set";
      }
      # {
      #   assertion = (lib.length cfg) != 0;
      #   message = "No monitors configured";
      # }
    ];
  };
}
