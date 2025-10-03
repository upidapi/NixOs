{
  lib,
  python3,
  fetchFromGitHub,
  buildarr,
  buildarr-sonarr,
  buildarr-radarr,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "buildarr-jellyseerr";
  version = "0.3.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "buildarr";
    repo = "buildarr-jellyseerr";
    rev = "v${version}";
    hash = "sha256-GGN40WfSqEUv+gLHzBoAkoEXmxbxh0B0GVgC/JFvtDU=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    buildarr
    buildarr-sonarr
    buildarr-radarr
  ];

  pythonImportsCheck = [
    "buildarr_jellyseerr"
    "buildarr"
  ];

  meta = {
    description = "Jellyseerr media request library application plugin for Buildarr";
    homepage = "https://github.com/buildarr/buildarr-jellyseerr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [hierocles];
    mainProgram = "buildarr";
  };
}
