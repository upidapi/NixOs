#{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; }
#, lib ? pkgs.lib
#, stdenv ? pkgs.stdenv
#, kernel ? pkgs.linux_latest
#, fetchFromGitLab ? pkgs.fetchFromGitLab
#, fetchpatch ? pkgs.fetchpatch
#, kmod ? pkgs.kmod
#, pahole ? pkgs.pahole
#}:
{
  lib,
  stdenv,
  fetchFromGitLab,
  kernel,
  kmod,
  pahole,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tuxedo-drivers-${kernel.version}";
  version = "4.4.1";

  src = fetchFromGitLab {
    owner = "tuxedocomputers/development/packages";
    repo = "tuxedo-drivers";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Bqxz4/3Oe9RAL0+7ZLFTkMF/EBnVkKA+ClzFd+D79WM=";
  };

  patches = [
    ./fix-dot-owner.patch
  ];

  buildInputs = [pahole];
  nativeBuildInputs = [kmod] ++ kernel.moduleBuildDependencies;

  makeFlags =
    kernel.makeFlags
    ++ [
      "KERNELRELEASE=${kernel.modDirVersion}"
      "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "INSTALL_MOD_PATH=$(out)"
    ];

  #installPhase = ''
  #  mkdir -p $out/etc/udev/rules.d
  #  cp ./99-z-tuxedo-systemd-fix.rules $out/etc/udev/rules.d/
  #'';

  meta = {
    broken = stdenv.isAarch64 || (lib.versionOlder kernel.version "5.5");
    description = "Drivers for several platform devices for TUXEDO notebooks";
    homepage = "https://gitlab.com/tuxedocomputers/development/packages/tuxedo-drivers";
    license = lib.licenses.gpl3Plus;
    longDescription = ''
      This driver provides support for Fn keys, brightness/color/mode for most TUXEDO
      keyboards (except white backlight-only models) and a hardware I/O driver for
      the TUXEDO Control center.
    '';
    maintainers = [lib.maintainers.aprl];
    platforms = lib.platforms.linux;
  };
})
