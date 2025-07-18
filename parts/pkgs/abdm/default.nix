# FROM: https://github.com/lonerOrz/lonerorz-nur/blob/e9edfba8c1eb4f6d8896cf5caada228b0a438fc9/pkgs/abdm/default.nix#L5
{
  autoPatchelfHook,
  makeWrapper,
  lib,
  stdenv,
  fetchurl,
  openjdk,
  zlib,
  alsa-lib,
  libglvnd,
  libXi,
  freetype,
  libXtst,
  libXrender,
  libX11,
  libXext,
  fontconfig,
  wayland,
  # dpkg,
  steam-run,
}:
stdenv.mkDerivation rec {
  owner = "amir1376";
  pname = "ab-download-manager";
  version = "1.6.2";

  # https://github.com/amir1376/ab-download-manager/releases/download/${version}/ABDownloadManager_${version}_linux_x64.tar.gz

  src = fetchurl {
    url = "https://github.com/${owner}/${pname}/releases/download/v${version}/ABDownloadManager_${version}_linux_x64.tar.gz";
    sha256 = "sha256-6aAtUni+g24YlhW9iu0qXkd3CUNZ60ObmbO8AasDgTQ=";
  };

  nativeBuildInputs = [autoPatchelfHook makeWrapper];

  buildInputs = [
    openjdk
    zlib
    alsa-lib
    libglvnd
    libXi
    freetype
    libXtst
    libXrender
    libX11
    libXext
    fontconfig
    wayland
    stdenv.cc.cc.lib
  ];

  # LD_LIBRARY_PATH=(pwd)/lib steam-run ./bin/ABDownloadManager

  propagatedBuildInputs = [libXext];

  unpackPhase = ''
    echo $src
    mkdir $out

    tar -xzf $src -C $out

    chmod +x $out/ABDownloadManager/bin/ABDownloadManager

    makeWrapper ${steam-run}/bin/steam-run $out/bin/${pname} \
      --add-flags $out/ABDownloadManager/bin/ABDownloadManager
  '';

  installPhase = ''
        mkdir -p $out/share/applications/${pname}

        cat <<EOF > "$out/share/applications/${pname}.desktop"
    [Desktop Entry]
    Name=AB Download Manager
    Comment=Manage and organize your download files better than before
    GenericName=Download Manager
    Categories=Utility;Network;
    Exec=$out/ABDownloadManager/bin/ABDownloadManager
    Icon=$out/ABDownloadManager/lib/ABDownloadManager.png
    Terminal=false
    Type=Application
    StartupWMClass=com-abdownloadmanager-desktop-AppKt
    EOF
  '';

  meta = with lib; {
    description = "A Download Manager that speeds up your downloads";
    # license = licenses.apache20;
    platforms = platforms.linux;
    maintainers = with maintainers; [];
    homepage = "https://abdownloadmanager.com/";
  };
}
