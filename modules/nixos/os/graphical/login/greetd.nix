{
  config,
  pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;

  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.meta) getExe;

  # env = config.modules.usrEnv;
  # sys = config.modules.system;

  # make desktop session paths available to greetd
  sessionData = config.services.displayManager.sessionData.desktops;
  sessionPaths = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];

  initialSession = {
    # TODO: make this configurable
    user = "upidapi"; # "${sys.mainUser}";
    command = "Hyprland"; # "${env.desktop}";
  };

  defaultSession = {
    user = "greeter";
    command = concatStringsSep " " [
      (getExe pkgs.greetd.tuigreet)
      "--time"
      "--remember"
      # TODO: impermanence probably fucks with this
      "--remember-user-session"
      "--asterisks"
      "--sessions '${sessionPaths}'"
    ];
  };

  cfg = config.modules.nixos.os.graphical.login.greetd;
in {
  options.modules.nixos.os.graphical.login.greetd =
    mkEnableOpt "enables the greetd login manager";

  config = mkIf cfg.enable {
    services.greetd.enable = true;
    /*
    services.greetd = {
      enable = true;
      vt = 2;
      # restart = !sys.autoLogin;

      # <https://man.sr.ht/~kennylevinsen/greetd/>
      settings = {
        # default session is what will be used if no session is selected
        # in this case it'll be a TUI greeter
        default_session = defaultSession;

        # initial session
        # initial_session = mkIf sys.autoLogin initialSession;
      };
    };

    # Suppress error messages on tuigreet. They sometimes obscure the TUI
    # boundaries of the greeter.
    # See: https://github.com/apognu/tuigreet/issues/68#issuecomment-1586359960
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInputs = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
    */
  };
}
