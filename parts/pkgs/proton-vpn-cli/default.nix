# REF: https://github.com/yuanw/nix-home/blob/ea651eaa421aeeeb63aeb12f2ffb23e124e8bd2b/packages/proton-vpn-cli/default.nix
# TODO: use the package in nixpkgs once it lands there
{
  python3,
  fetchFromGitHub,
  # setuptools,
  lib,
  # Python dependencies
  # proton-core,
  # proton-vpn-api-core,
  # proton-keyring-linux,
  # proton-vpn-network-manager,
  # proton-vpn-local-agent,
  # click,
  # dbus-fast,
  # packaging,
  # For tests (optional)
}:
python3.pkgs.buildPythonApplication {
  pname = "proton-vpn-cli";
  version = "0.1.2";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "ProtonVPN";
    repo = "proton-vpn-cli";
    # rev = "refs/heads/stable"; # No tags available, using stable branch
    rev = "7f258f8a79618571d3a6cf38e2e2273abe982b94";
    hash = "sha256-Hn7xLb7VWa2dlsrQnjnRgv+8UntOwDak9+rV1HF7k80=";
  };

  build-system = with python3.pkgs; [setuptools];

  propagatedBuildInputs = with python3.pkgs; [
    proton-core
    proton-vpn-api-core
    proton-keyring-linux
    proton-vpn-network-manager
    proton-vpn-local-agent
    click
    dbus-fast
    packaging
  ];

  # Disable tests for now as they may require additional setup
  doCheck = false;

  # Optional: Enable tests if needed
  # nativeCheckInputs = [
  #   pytestCheckHook
  #   pytest-asyncio
  # ];
  #
  # preCheck = ''
  #   export HOME=$TMPDIR
  # '';

  meta = {
    description = "Official Proton VPN command-line interface for Linux";
    homepage = "https://github.com/ProtonVPN/proton-vpn-cli";
    license = lib.licenses.gpl3Only;
    mainProgram = "protonvpn";
    platforms = lib.platforms.linux;
  };
}
