{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.free-cad;

  freecad = let
    pname = "freecad";
    version = "weekly-2026.01.07";

    # https://github.com/FreeCAD/FreeCAD/releases/download/weekly-2026.01.07/FreeCAD_weekly-2026.01.07-Linux-x86_64-py311.AppImage
    src = pkgs.fetchurl {
      url = "https://github.com/FreeCAD/FreeCAD/releases/download/${version}/FreeCAD_${version}-Linux-x86_64-py311.AppImage";
      hash = "sha256-js5TMASYoWcJWZw9xnTmXD8Bpr7bgV4fdEPLwSCqoIE=";
    };

    appimageContents = pkgs.appimageTools.extractType2 {inherit pname version src;};
  in
    pkgs.appimageTools.wrapType2 {
      inherit pname version src;

      extraInstallCommands = ''
        install -m 444 -D ${appimageContents}/org.freecad.FreeCAD.desktop -t $out/share/applications
        mkdir -p $out/share/icons
        cp -r ${appimageContents}/usr/share/icons/hicolor $out/share/icons
        substituteInPlace $out/share/applications/org.freecad.FreeCAD.desktop \
          --replace 'Exec=AppRun - --single-instance %F' 'Exec=freecad'
      '';

      extraPkgs = pkgs:
        with pkgs; [
          coin3d
          eigen
          fmt
          gts
          hdf5
          libGLU
          # libXmu
          libspnav
          medfile
          ode
          xercesc
          yaml-cpp
          zlib
          opencascade-occt
          microsoft-gsl
          qt6.qtbase
          qt6.qtsvg
          qt6.qttools
          qt6.qtwayland
          qt6.qtwebengine
        ];
    };
in {
  options.modules.home.apps.free-cad = mkEnableOpt "";

  config = mkIf cfg.enable {
    home.packages = [freecad];
  };
}
