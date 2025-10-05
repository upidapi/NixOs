{
  lib,
  python3,
  fetchFromGitHub,
  click-params,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "buildarr";
  version = "0.8.0b1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Jahn16";
    repo = "buildarr";
    rev = "main";
    # hash = "sha256-MMpPFUXicGlreXxvYoGcVEct8ICyuvoRQKxpmRi4jSo="; # v0.7.1
    #hash = "sha256-2lXUW4B3KfIOn1tS9RsjwDoy/Hom4bXbO4vdd8NXoZQ="; # v0.8.0b1 - currently has incompatibilities with downstream packages
    # hash = "sha256-2lXUW4B3KfIOn1tS9RsjwDoy/Hom4bXbO4vdd8NXoZQ=";
    hash = "sha256-it5zrpsf6ybBznXgs8I9El1tArV9m5jKkQ7R0yBiDFc=";
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core # v0.7.1 requires poetry-core
    setuptools
    wheel
    setuptools_scm
    #pdm-pep517
    #setuptools-scm
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aenum
    click
    click-params
    importlib-metadata
    pydantic
    #v0.7.1 requires pydantic < 2.0.0
    # (pydantic_1.overridePythonAttrs (old: {
    #   propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ old.optional-dependencies.email;
    # }))

    pyyaml
    requests
    schedule
    stevedore
    typing-extensions
    watchdog

    distutils
  ];

  pythonImportsCheck = [
    "buildarr"
  ];

  meta = {
    description = "Constructs and configures Arr PVR stacks";
    homepage = "https://github.com/buildarr/buildarr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [hierocles];
    mainProgram = "buildarr";
  };
}
