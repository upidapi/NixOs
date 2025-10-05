{
  lib,
  python3,
  fetchFromGitHub,
  buildarr,
}: let
  radarr-py = python3.pkgs.buildPythonPackage rec {
    pname = "radarr-py";
    version = "1.2.1";
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
      owner = "Jahn16";
      repo = "buildarr-radarr";
      rev = "main";
      # hash = "sha256-4Asj04pH/6+SlY1tUahyE6dQ4/zUGf0caphfbqFuvRc=";
      hash = "sha256-9SSeguKj4+f0l2DZ+imhWZuR+xrYdyt+F3M+mHeJW9I=";
    };

    nativeBuildInputs = with python3.pkgs; [
      poetry-core
      setuptools
      wheel
      setuptools_scm
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
