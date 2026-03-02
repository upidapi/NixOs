{
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  nodejs,
  tree,
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
  makeWrapper,
  openssl,
  stdenv,
  xorg,
  xcb-util-cursor,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "ida-pro";
  version = "9.2";

  src = ./ida-pro_92_x64linux.run;

  icon = fetchurl {
    urls = [
      "https://web.archive.org/web/20221105181235im_/https://hex-rays.com/products/ida/news/8_1/images/icon_teams.png"
    ];
    hash = "sha256-gjb999iszr6gqlJJjMJ6mMU8EJHbOSgIdFfbgUx8hkM=";
  };

  desktopItem = makeDesktopItem {
    name = "ida-pro";
    exec = "ida64";
    icon = icon;
    comment = "IDA Pro 9.2";
    desktopName = "IDA Pro 9.2";
    genericName = "Interactive Disassembler";
    categories = ["Development"];
    startupWMClass = "IDA";
  };

  desktopItems = [desktopItem];

  nativeBuildInputs = [
    tree
    makeWrapper
    copyDesktopItems
    autoPatchelfHook
    nodejs
  ];

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
    xorg.xcbutil
    xcb-util-cursor
    zlib
  ];
  buildInputs = runtimeDependencies;

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

    # Copy the Node.js keygen to the installation directory
    cp ${./kg_patch/keygen.js} $IDADIR/keygen.js

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

    # Copy the libraries to the lib directory to patch ida
    cp $IDADIR/libida.so $out/lib
    cp $IDADIR/libida32.so $out/lib

    # Some libraries come with the installer.
    addAutoPatchelfSearchPath $IDADIR

    # Simple wrappers that prioritize IDA's own libraries
    for bb in ida ida64 assistant; do
      if [ -f $IDADIR/$bb ]; then
        makeWrapper $IDADIR/$bb $out/bin/$bb \
          --prefix LD_LIBRARY_PATH : $IDADIR \
          --set QT_PLUGIN_PATH $IDADIR/plugins/platforms \
          --chdir $IDADIR
      fi
    done

    # runtimeDependencies don't get added to non-executables, and openssl is needed
    # for cloud decompilation (lumina)
    if [ -f $IDADIR/libida.so ]; then
      patchelf --add-needed libcrypto.so $IDADIR/libida.so
    fi
    if [ -f $IDADIR/libida64.so ]; then
      patchelf --add-needed libcrypto.so $IDADIR/libida64.so
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Interactive Disassembler Pro 9.2";
    homepage = "https://hex-rays.com/ida-pro/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [];
  };
}
