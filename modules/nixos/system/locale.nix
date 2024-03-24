{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.system.locale;
in {
  options.modules.nixos.system.locale = mkEnableOpt (
    "sets variuos locale stuff like"
    + "lang, kb layout, time zone, etc"
  );

  # todo the problem is here
  config = mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "Europe/Stockholm";

    # Select internationalisation properties.
    i18n = {
      defaultLocale = "en_GB.UTF-8";

      extraLocaleSettings = {
        LC_ADDRESS = "sv_SE.UTF-8";
        LC_IDENTIFICATION = "sv_SE.UTF-8";
        LC_MEASUREMENT = "sv_SE.UTF-8";
        LC_MONETARY = "sv_SE.UTF-8";
        LC_NAME = "sv_SE.UTF-8";
        LC_NUMERIC = "sv_SE.UTF-8";
        LC_PAPER = "sv_SE.UTF-8";
        LC_TELEPHONE = "sv_SE.UTF-8";
        LC_TIME = "sv_SE.UTF-8";
      };
    };

    # probably move the following to hardware/keyboard
    # Configure console keymap
    console.keyMap = "sv-latin1";
    # console.useXkbConfig = true;

    # Configure keymap
    # "xserver" is actually just the general display server
    # so this actually configs wayland too.
    services.xserver.xkb = {
      layout = "se";
      variant = "";

      # replace caps with esc, bc ... well fuck caps
      # this doen't work
      options = "caps:escape";
    };
  };
}
