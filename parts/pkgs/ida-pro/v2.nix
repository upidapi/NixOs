{
  autoPatchelfHook,
  cairo,
  python3,
  copyDesktopItems,
  dbus,
  fetchurl,
  fontconfig,
  freetype,
  glib,
  gtk3,
  lib,
  libdrm,
  libGL,
  libkrb5,
  libsecret,
  libsForQt5,
  libunwind,
  libxkbcommon,
  makeDesktopItem,
  makeWrapper,
  openssl,
  stdenv,
  xorg,
  zlib,
  wrapGAppsHook3,
  ## crack
  requireFile,
  unzip,
}: let
  # remove ~/.idapro if theres issues with it not finding the license file
  crack-py = requireFile {
    name = "crack_ida90_beta.py";
    url = "https://rutracker.org/forum/viewtopic.php?t=6560957";
    sha256 = "337775c3bfbec7e95a2d28ef88ecc4ae0a2dc775ea5fcdbeb8ab7b7771decf59";
  };
in
  stdenv.mkDerivation rec {
    pname = "ida-pro";
    # version = "9.0.240807";
    version = "9.2";

    src = requireFile {
      name = "ida-free-pc_${lib.replaceStrings ["."] [""] version}_x64linux.run";
      url = "https://auth.lol/ida/";
      # sha256 = "0b12a798f0e2ab7c5b7a795eb275136af7fce88356fddefd7f7776c6aa588372";
    };

    icon = fetchurl {
      url = "https://web.archive.org/web/20221105181231if_/https://hex-rays.com/products/ida/news/8_1/images/icon_free.png";
      sha256 = "sha256-widkv2VGh+eOauUK/6Sz/e2auCNFAsc8n9z0fdrSnW0=";
    };

    desktopItem = makeDesktopItem {
      name = "ida-pro";
      exec = "ida64";
      icon = icon;
      comment = meta.description;
      desktopName = "IDA Pro";
      genericName = "Interactive Disassembler";
      categories = ["Development"];
      startupWMClass = "IDA";
    };

    desktopItems = [desktopItem];

    nativeBuildInputs = [
      wrapGAppsHook3
      makeWrapper
      copyDesktopItems
      autoPatchelfHook
      libsForQt5.wrapQtAppsHook
      unzip
      python3
    ];

    # We just get a runfile in $src, so no need to unpack it.
    dontUnpack = true;

    # Add everything to the RPATH, in case IDA decides to dlopen things.
    runtimeDependencies = [
      cairo
      dbus
      fontconfig
      freetype
      glib
      gtk3
      libdrm
      libGL
      libkrb5
      libsecret
      libsForQt5.qtbase
      libsForQt5.qt5.qtwayland
      libunwind
      libxkbcommon
      openssl
      stdenv.cc.cc
      xorg.libICE
      xorg.libSM
      xorg.libX11
      xorg.libXau
      xorg.libxcb
      xorg.libXext
      xorg.libXi
      xorg.libXrender
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.xcbutilwm
      zlib
    ];
    buildInputs = runtimeDependencies;

    dontWrapQtApps = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/lib $out/opt

      # IDA depends on quite some things extracted by the runfile, so first extract everything
      # into $out/opt, then remove the unnecessary files and directories.
      IDADIR=$out/opt


      # Invoke the installer with the dynamic loader directly, avoiding the need
      # to copy it to fix permissions and patch the executable.
      $(cat $NIX_CC/nix-support/dynamic-linker) $src \
        --mode unattended --prefix $IDADIR


      # Copy the exported libraries to the output.
      cp $IDADIR/libida64.so $out/lib

      # Some libraries come with the installer.
      addAutoPatchelfSearchPath $IDADIR

      for bb in ida64 assistant; do
        wrapProgram $IDADIR/$bb \
          --set QT_QPA_PLATFORM xcb \
          --prefix QT_PLUGIN_PATH : $IDADIR/plugins/platforms
        ln -s $IDADIR/$bb $out/bin/$bb
      done

      ## crack part
      cd $out/opt
      python3 ${crack-py}
      cd -
      for f in $out/opt/*.patched; do
        mv -f $f "$(echo $f | sed -e 's/\.patched//')"
      done
      ## endof crackpart

      # runtimeDependencies don't get added to non-executables, and openssl is needed
      #  for cloud decompilation
      patchelf --add-needed libcrypto.so $IDADIR/libida64.so

      runHook postInstall
    '';

    meta = with lib; {
      description = "Paid version of the world's smartest and most feature-full disassembler";
      homepage = "https://hex-rays.com/ida-free/";
      changelog = "https://hex-rays.com/products/ida/news/";
      # license = licenses.unfree; # unfree packages are a pain to deal with on nixos
      mainProgram = "ida64";
      # maintainers = with maintainers; [msanft];
      platforms = ["x86_64-linux"]; # Right now, the installation script only supports Linux.
      sourceProvenance = with sourceTypes; [binaryNativeCode];
    };
  }
