{python3}:
python3.pkgs.buildPythonApplication {
  pname = "qs";
  version = "1.0";
  pyproject = true;

  src = ./.;
  nativeBuildInputs = [
    python3.pkgs.setuptools
  ];

  # propagatedBuildInputs = [python3.pkg.requests];

  meta = {
    description = "helper cli tool for working with nixos";
    mainProgram = "qs";
  };
}
