{
  autoPatchelfHook,
  cairo,
  nodejs,
  makeWrapper,
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
  libunwind,
  libxkbcommon,
  makeDesktopItem,
  requireFile,
  openssl,
  stdenv,
  libICE,
  libSM,
  libX11,
  libXau,
  libxcb,
  libXext,
  libXi,
  libXrender,
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  xcbutilwm,
  xcbutil,
  xcb-util-cursor,
  zlib,
  #
  fetchFromGitHub,
  python3,
  ...
}: let
  # cd /raid/media/torrents/ida93sp1/
  # nix-store --add-fixed sha256 kg_patch/keygen.js
  # nix-store --add-fixed sha256 ida-pro_93_x64linux.run
  # nix-hash --type sha256 --base64 keygen.js
  crack-js = requireFile {
    name = "keygen.js";
    # message = "ida92/kg_patch/keygen.js";
    url = "https://auth.lol/ida/";
    sha256 = "1y4491g1l9jklhmai94x1rr4b2x1k6zd3xpi1zzjc1f3vn31brs1";
  };

  ebpf-processor = fetchFromGitHub {
    owner = "zandi";
    repo = "eBPF_processor";
    rev = "6cc4782";
    hash = "sha256-C0cC+HPBr/LYCIE4cgy0fkdKCB8P/lkgRxtR4NiDlJ8=";
  };

  # https://github.com/dracula/ida
  dracula-theme = fetchFromGitHub {
    owner = "dracula";
    repo = "ida";
    rev = "bfe394d";
    hash = "sha256-Usru4URPGUXcF9Asi6Ok/NA9s7IX8S2LhmpigFe/r58=";
  };

  pythonForIDA = python3.withPackages (ps:
    with ps; [
      rpyc
      pyelftools
    ]);
in
  stdenv.mkDerivation rec {
    pname = "ida-pro";
    # version = "9.0.240807";
    version = "9.3";

    src = requireFile {
      name = "ida-pro_${lib.replaceStrings ["."] [""] version}_x64linux.run";
      url = "https://auth.lol/ida/";
      sha256 = "1qass0401igrfn14sfrvjfyz668npx586x59yaa4zf3jx650zpda";
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

    # Configure autoPatchelfHook to ignore Qt6 libraries that IDA ships with because SOMEHOW it gives fuckass errors
    autoPatchelfIgnoreMissingDeps = [
      "libQt6WaylandCompositor.so.6"
      "libQt6EglFSDeviceIntegration.so.6"
      "libQt6WlShellIntegration.so.6"
      "libQt6Network.so.6"
      "libQt6Svg.so.6"
      "libQt6Core.so.6"
      "libQt6Gui.so.6"
      "libQt6Widgets.so.6"
    ];

    # We just get a runfile in $src, so no need to unpack it.
    dontUnpack = true;

    # Add only essential system libraries that IDA doesn't ship with
    # IDA Pro 9.2 ships with its own Qt6 libraries, so fuck Qt6
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
      libunwind
      libxkbcommon
      openssl
      stdenv.cc.cc
      libICE
      libSM
      libX11
      libXau
      libxcb
      libXext
      libXi
      libXrender
      xcbutilimage
      xcbutilkeysyms
      xcbutilrenderutil
      xcbutilwm
      xcbutil
      xcb-util-cursor
      zlib
      pythonForIDA
    ];

    buildInputs =
      runtimeDependencies
      ++ [
        nodejs
        autoPatchelfHook
        makeWrapper
      ];

    dontWrapQtApps = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/lib $out/opt $out/share/applications

      # IDA depends on quite some things extracted by the runfile, so first extract everything
      # into $out/opt, then remove the unnecessary files and directories.
      IDADIR=$out/opt

      export XDG_DATA_HOME=$out/share

      # Invoke the installer with the dynamic loader directly, avoiding the need
      # to copy it to fix permissions and patch the executable.
      $(cat $NIX_CC/nix-support/dynamic-linker) $src \
        --mode unattended --prefix $IDADIR

      # Link the exported libraries to the output.
      for lib in $IDADIR/libida*; do
        ln -s $lib $out/lib/$(basename $lib)
      done

      # # Copy the libraries to the lib directory to patch ida
      # cp $IDADIR/libida.so $out/lib
      # cp $IDADIR/libida32.so $out/lib

      # Copy the Node.js keygen to the installation directory
      cp ${crack-js} $IDADIR/keygen.js

      # Run the Node.js keygen to generate license and patch libraries
      cd $IDADIR/
      node keygen.js
      cd -

      # Copy the generated license to the proper location
      if [ -f $IDADIR/idapro.hexlic ]; then
        echo "License generated successfully"
      else
        echo "Warning: License generation may have failed"
      fi

      # Some libraries come with the installer.
      addAutoPatchelfSearchPath $IDADIR

      # Simple wrappers that prioritize IDA's own libraries
      for bb in ida ida64 assistant; do
        if [ -f $IDADIR/$bb ]; then
          wrapProgram $IDADIR/$bb \
            --prefix IDADIR : $IDADIR \
            --prefix QT_PLUGIN_PATH : $IDADIR/plugins/platforms \
            --prefix PYTHONPATH : $out/opt/idalib/python \
            --prefix PATH : ${pythonForIDA}/bin:$IDADIR \
            --prefix LD_LIBRARY_PATH : $out/lib
          ln -s $IDADIR/$bb $out/bin/$bb

          # makeWrapper $IDADIR/$bb $out/bin/$bb \
          #   --prefix IDADIR : $IDADIR \
          #   --prefix LD_LIBRARY_PATH : $IDADIR \
          #   --prefix PYTHONPATH : $out/opt/idalib/python \
          #   --prefix PATH : ${pythonForIDA}/bin:$IDADIR \
          #   --set QT_PLUGIN_PATH $IDADIR/plugins/platforms \
          #   --chdir $IDADIR
        fi
      done

      # Manually patch libraries that dlopen stuff.

      # runtimeDependencies don't get added to non-executables, and openssl is needed
      # for cloud decompilation (lumina)
      if [ -f $IDADIR/libida.so ]; then
        patchelf --add-needed libcrypto.so $IDADIR/libida.so
        patchelf --add-needed libpython3.13.so $IDADIR/libida.so
        patchelf --add-needed libsecret-1.so.0 $IDADIR/libida.so
      fi
      if [ -f $IDADIR/libida64.so ]; then
        patchelf --add-needed libcrypto.so $IDADIR/libida64.so
        patchelf --add-needed libpython3.13.so $IDADIR/libida64.so
        patchelf --add-needed libsecret-1.so.0 $IDADIR/libida64.so
      fi

      # add plugins
      # should not do anything,
      # but my ebpf processor from a plugins disappears if i remove this
      cp ${ebpf-processor}/ebpf.py $out/opt/procs/

      # add themes
      mkdir -p $out/opt/themes/dracula-v2
      cp ${dracula-theme}/theme.css $out/opt/themes/dracula-v2

      cp "$IDADIR/dbgsrv/linux_server" "$out/bin/ida-linux-server"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Interactive Disassembler Pro";
      homepage = "https://hex-rays.com/ida-pro/";
      # license = licenses.unfree; # TODO: switch back when i fix it
      license = licenses.gpl3;
      platforms = platforms.linux;
      maintainers = [];
    };
  }
