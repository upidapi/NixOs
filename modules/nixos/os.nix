{lib, ...}: let
  inherit (lib) nullOr str mkOption;
in {
  options.modules.nixos.os = {
    primaryUser = mkOption {
      type = nullOr str;
      description = ''
        The primary user of the system, eg used for auto login incase of full
        disc encryption.
      '';
    };

    adminUser = mkOption {
      type = nullOr str;
      description = ''
        The user in control. Not the admin account, but the account that can
        elavate itselt to admin
      '';
    };
  };
}
