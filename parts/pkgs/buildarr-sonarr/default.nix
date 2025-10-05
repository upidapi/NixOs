{
  lib,
  python3,
  fetchFromGitHub,
  buildarr,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "buildarr-sonarr";
  version = "0.7.0b1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Jahn16";
    repo = "buildarr-sonarr";
    rev = "main";
    hash = "sha256-w7izZKEMRif9nE31fNAyljjqDwKztP98doTq6b65GSU=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
    setuptools
    wheel
    setuptools_scm
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
