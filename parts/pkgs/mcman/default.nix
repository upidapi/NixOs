# REF: https://github.com/IogaMaster/flux/blob/400896b5c977e0569ea0f8bacb9b42509e0bbd00/pkgs/mcman/default.nix
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  bzip2,
  zstd,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "mcman";
  version = "0.4.5";

  # https://github.com/deniz-blue/mcman/releases/tag/0.4.5
  src = fetchFromGitHub {
    owner = "deniz-blue";
    repo = "mcman";
    # rev = version;
    rev = "${version}";
    hash = "sha256-/WIm2MFj2++QVCATDkYz2h4Jm+0RzxzVFIYrZubEgIQ=";
  };

  cargoHash = "sha256-/tN2liNeTUBM9HERe/Z/pqB/5Bb5PciM3GcNpwomr0Y=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      bzip2
      zstd
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.CoreServices
      darwin.apple_sdk.frameworks.Security
    ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = with lib; {
    description = "Powerful Minecraft Server Manager CLI. Easily install jars (server, plugins & mods) and write config files. Docker and git support included";
    homepage = "https://github.com/ParadigmMC/mcman";
    changelog = "https://github.com/ParadigmMC/mcman/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    # maintainers = with maintainers; [iogamaster];
    mainProgram = "mcman";
  };
}
