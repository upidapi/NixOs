{
  config,
  lib,
  pkgs,
  mlib,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf;
  inherit (builtins) fetchFromGitHub;

  # not used
  cursors = {
    McMojave = pkgs.stdenv.mkDerivation {
      name = "McMojave";
      src = fetchFromGitHub {
        owner = "OtaK";
        repo = "McMojave-hyprcursor";
        rev = "main";
        sha256 = "sha256-+Qo88EJC0nYDj9FDsNtoA4nttck81J9CQFgtrP4eBjk=";
      };

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/icons/McMojave
        cp -R dist/* $out/share/icons/McMojave/

        runHook postInstall
      '';
    };

    bibata-ice = pkgs.stdenv.mkDerivation {
      pname = "bibata-hyprcursors";
      version = "1.0";

      src = pkgs.fetchzip {
        url = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/1.0/hypr_Bibata-Modern-Ice.tar.gz";
        hash = "sha256-Ji5gqIBrAtFO3S9fCrY/LXPaq5gCY4CkxZJ1uAcjj70=";
        stripRoot = false;
      };

      installPhase = ''
        mkdir -p $out
        cp -rf . $out
      '';
    };
  };

  # ref: https://github.com/leiserfg/nix-config/blob/a209d80575d30924f7c54ff1d1831850efb91c1a/home/leiserfg/features/hyprland.nix#L10
  cursor = "Bibata-Modern-Ice";
  cursorPackage = cursors.bibata-ice;

  cfg = config.modules.home.desktop.hyprcursor;
in {
  options.modules.home.desktop.hyprcursor =
    mkEnableOpt "Enables hyprcursors";

  config = mkIf cfg.enable {
    home.packages = [
      cursorPackage
    ];

    # xdg.dataFile.".icons/${cursor}".source = "${cursorPackage}/share/icons/${cursor}";

    home.file = {
      ".icons/${cursor}" = {
        source = "${cursorPackage}/share/icons/${cursor}";
      };
    };
  };
}
