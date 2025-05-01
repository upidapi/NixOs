{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.bt-dualboot;

  bt-dualboot = pkgs.python3Packages.buildPythonApplication rec {
    pname = "bt-dualboot";
    version = "1.0.1";
    pyproject = true;

    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-pjzGvLkotQllzyrnxqDIjGlpBOvUPkWpv0eooCUrgv8=";
    };

    dependencies = [
      pkgs.python3Packages.poetry-core
    ];

    meta = with lib; {
      homepage = "https://pypi.org/project/bt-dualboot/";
      description = "Sync Bluetooth for dualboot Linux and Windows";
      license = licenses.mit;
    };
  };

  bt-sync = pkgs.writeShellScriptBin "bt-sync" ''
    if [[ $# -eq 0 ]]; then
      echo "Error: windows partition not provided" >&2
      echo "Usage: " >&2
      echo "bt-sync nvme0n1" >&2
      exit 1
    fi

    mount --mkdir /dev/$1 /mnt/win
    ${bt-dualboot}/bin/bt-dualboot --win /mnt/win --sync-all --no-backup
    umount -R /mnt/win
  '';
in {
  options.modules.home.cli-apps.bt-dualboot = mkEnableOpt "enable bt-dualboot and bt-sync command";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      chntpw
      bt-dualboot
      bt-sync
    ];
  };
}
