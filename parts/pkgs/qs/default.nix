{python3}:
python3.pkgs.buildPythonApplication {
  pname = "qs";
  version = "1.0";
  pyproject = true;

  src = ./.;
  nativeBuildInputs = with python3.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pyyaml
  ];

  # propagatedBuildInputs = [python3.pkg.requests];

  meta = {
    description = "helper cli tool for working with nixos";
    mainProgram = "qs";
  };
}
