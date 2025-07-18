{
  pkgs ? import <nixpkgs> {},
  lib,
  fetchFromGitHub,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "prelockd";
  version = "v0.9-de0870e";
  src = fetchFromGitHub {
    owner = "hakavlad";
    repo = pname;
    rev = "de0870e";
    sha256 = "sha256-NlDXECD1PPVLXWuhyEEoZH2GOSIKh8feXqPbn89A62o=";
  };
  propagatedBuildInputs = with pkgs; [python3];

  installPhase = ''
    runHook preInstall

    PREFIX= DESTDIR=$out SYSTEMDUNITDIR=/lib/systemd/system SYSCONFDIR=/etc make base units

    substituteInPlace $out/lib/systemd/system/prelockd.service \
      --replace "ExecStart=" "ExecStart=$out"

    runHook postInstall
  '';
}
