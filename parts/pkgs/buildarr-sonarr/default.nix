{
  lib,
  python3,
  fetchFromGitHub,
  buildarr,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "buildarr-sonarr";
  version = "0.6.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "buildarr";
    repo = "buildarr-sonarr";
    rev = "v${version}";
    hash = "sha256-H0M3EK+b4Q0Odh12pWOYZOn5ASr0MU8s/fSTgYK17TI=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    buildarr
    importlib-metadata
    json5
    pexpect
    requests
  ];

  pythonImportsCheck = [
    "buildarr"
    "buildarr_sonarr"
  ];

  meta = {
    description = "Sonarr PVR plugin for Buildarr ";
    homepage = "https://github.com/buildarr/buildarr-sonarr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [hierocles];
    mainProgram = "buildarr";
  };
}
