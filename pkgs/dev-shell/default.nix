{
  lib,
  python3,
  stdenv,
  installShellFiles,
}:
python3.pkgs.buildPythonApplication {
  pname = "dev-shell";
  version = "1.0";
  format = "pyproject";

  src = ./.;
  nativeBuildInputs = [
    python3.pkgs.setuptools
    installShellFiles
  ];

  propagatedBuildInputs = with python3.pkgs; [
    argcomplete
  ];
  # doCheck = true;

  postInstall = let
    argcomplete = (
      lib.getExe'
      python3.pkgs.argcomplete
      "register-python-argcomplete"
    );
  in
    lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform)
    ''
      installShellCompletion --cmd dev-shell \
        --bash <(${argcomplete} --shell bash dev-shell) \
        --zsh <(${argcomplete} --shell zsh dev-shell) \
        --fish <(${argcomplete} --shell fish dev-shell)
    '';

  meta = {
    # with lib; {
    description = "helper tool to quickly open dev shells";
    # homepage = "";
    # changelog = "";
    # license = licenses.mit;
    mainProgram = "dev-shell";
    # maintainers = with maintainers; [];
  };
}
