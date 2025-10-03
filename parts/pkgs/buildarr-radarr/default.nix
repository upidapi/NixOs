{
  lib,
  python3,
  fetchFromGitHub,
  buildarr,
}: let
  radarr-py = python3.pkgs.buildPythonPackage rec {
    pname = "radarr-py";
    version = "0.4.0";
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "devopsarr";
      repo = "radarr-py";
      rev = "v${version}";
      hash = "sha256-yFutT9yHeIsQxxoiuwFsV1pQDuvj7ygdTL9RcHPr24E=";
    };

    propagatedBuildInputs = with python3.pkgs; [
      requests
    ];

    doCheck = false;
  };
in
  python3.pkgs.buildPythonApplication rec {
    pname = "buildarr-radarr";
    version = "0.2.6";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "buildarr";
      repo = "buildarr-radarr";
      rev = "v${version}";
      hash = "sha256-4Asj04pH/6+SlY1tUahyE6dQ4/zUGf0caphfbqFuvRc=";
    };

    nativeBuildInputs = with python3.pkgs; [
      poetry-core
    ];

    buildInputs = [
      radarr-py
    ];

    propagatedBuildInputs =
      [
        buildarr
        radarr-py
      ]
      ++ (with python3.pkgs; [
        dateutil
      ]);

    makeWrapperArgs = [
      "--prefix PYTHONPATH : ${radarr-py}/${python3.sitePackages}"
    ];

    pythonImportsCheck = [
      "buildarr_radarr"
      "buildarr"
    ];

    meta = {
      description = "Radarr PVR plugin for Buildarr";
      homepage = "https://github.com/buildarr/buildarr-radarr";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [hierocles];
      mainProgram = "buildarr";
    };
  }
