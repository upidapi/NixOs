# package.nix
{
  stdenv,
  python312Packages,
}:
python312Packages.buildPythonApplication {
  pname = "codexctl";
  version = "2025-07-19-18-10";
  pyproject = true;

  src = ./.;

  build-system = [
    python312Packages.poetry-core
  ];

  dependencies = with python312Packages; [
    paramiko
    psutil
    requests
    loguru
    # Conditional dependencies based on OS
    (
      if stdenv.hostPlatform.isLinux
      then remarkable-update-fuse
      else remarkable-update-image
    )
  ];

  meta = {
    description = "CLI tool codexctl";
    mainProgram = "codexctl";
  };
}
