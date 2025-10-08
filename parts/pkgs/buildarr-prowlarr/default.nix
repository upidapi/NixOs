{
  lib,
  python3,
  fetchFromGitHub,
  buildarr,
  buildarr-sonarr,
  buildarr-radarr,
  # email_validator,
}: let
  prowlarr-py = python3.pkgs.buildPythonPackage rec {
    pname = "prowlarr-py";
    version = "1.1.1";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "devopsarr";
      repo = "prowlarr-py";
      rev = "v${version}";
      hash = "sha256-2QR5BnbzOxS6/ivtX5NCn/+Cp3/h4kySV6lhj0+kAcA=";
    };

    nativeBuildInputs = with python3.pkgs; [
      setuptools
      wheel
    ];

    propagatedBuildInputs = with python3.pkgs; [
      urllib3
      python-dateutil
      # pydantic
      (pydantic_1.overridePythonAttrs (old: {
        propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ old.optional-dependencies.email;
      }))
      # (pydantic_1.overridePythonAttrs (old: {
      #   version = "1.10.12";
      #
      #   doCheck = false;
      #   src = python3.pkgs.fetchPypi {
      #     pname = "pydantic";
      #     version = "1.10.10";
      #     hash = "sha256-O41b2XiG+etZJgWUIHyfV9zhSm+GnGzuqQGIcV0pkho=";
      #   };
      # }))
      typing-extensions
      requests
      aenum
    ];

    pythonImportsCheck = ["prowlarr"];

    meta = with lib; {
      description = "Prowlarr API wrapper";
      homepage = "https://github.com/devopsarr/prowlarr-py";
      license = licenses.mpl20;
    };
  };
in
  python3.pkgs.buildPythonApplication rec {
    pname = "buildarr-prowlarr";
    version = "0.5.3";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "Jahn16";
      repo = "buildarr-prowlarr";
      rev = "main";
      # hash = "sha256-Az5SRjgkNDthdDTsqniKAwz/J6EisDkXAqR5/0UQets=";
    };

    nativeBuildInputs = with python3.pkgs; [
      poetry-core
    ];

    buildInputs = [
      prowlarr-py
    ];

    propagatedBuildInputs =
      [
        buildarr
        buildarr-sonarr
        buildarr-radarr
        prowlarr-py
      ]
      ++ (with python3.pkgs; [
        dateutil
      ]);

    makeWrapperArgs = [
      "--prefix PYTHONPATH : ${prowlarr-py}/${python3.sitePackages}"
    ];

    pythonImportsCheck = [
      "buildarr_prowlarr"
      "buildarr"
    ];

    meta = {
      description = "Prowlarr PVR plugin for Buildarr";
      homepage = "https://github.com/buildarr/buildarr-prowlarr";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [hierocles];
      mainProgram = "buildarr";
    };
  }
