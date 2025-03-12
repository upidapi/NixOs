{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    poetry2nix.url = "github:nix-community/poetry2nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    self,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        inherit
          (inputs.poetry2nix.lib.mkPoetry2Nix {
            inherit pkgs;
          })
          mkPoetryApplication
          mkPoetryEnv
          ;

        deps = with pkgs; [
        ];
      in {
        packages.default = mkPoetryApplication {
          projectDir = self;
          postInstall = let
            argcomplete =
              pkgs.lib.getExe'
              pkgs.python3.pkgs.argcomplete
              "register-python-argcomplete";
          in ''
            wrapProgram "$out/bin/default" \
              --prefix PATH : ${pkgs.lib.makeBinPath deps}

            installShellCompletion --cmd ${
              "the name of cmd"
              /*
              todo
              */
            } \
              --bash <(${argcomplete} --shell bash dev-shell) \
              --zsh <(${argcomplete} --shell zsh dev-shell) \
              --fish <(${argcomplete} --shell fish dev-shell)
          '';

          nativeBuildInputs = with pkgs; [
            installShellFiles
          ];

          # doCheck = true;

          meta = {
            # with lib; {
            # description = "";
            # homepage = "";
            # changelog = "";
            # license = licenses.;
            # mainProgram = "";
            # maintainers = with maintainers; [];
          };
        };

        # REF: https://nixos.org/manual/nixpkgs/stable/#how-to-consume-python-modules-using-pip-in-a-virtual-environment-like-i-am-used-to-on-other-operating-systems
        devShells.default = pkgs.mkShell {
          name = "py-venv";
          venvDir = "./.venv";
          buildInputs = with pkgs.python3Packages;
            [
              # A Python interpreter including the 'venv' module is required to
              # bootstrap the environment.
              python

              # This executes some shell code to initialize a venv in $venvDir
              # before dropping into the shell
              venvShellHook

              # Those are dependencies that we would like to use from nixpkgs,
              # which will add them to PYTHONPATH and thus make them accessible
              # from within the venv.
              # has to be installed here for some reason
              # numpy
              # requests
            ]
            ++ (with pkgs; [
              # In this particular example, in order to compile any binary
              # extensions they may require, the Python modules listed in the
              # hypothetical requirements.txt need  the following packages to
              # be installed locally:
              # taglib
              # openssl
              # git
              # libxml2
              # libxslt
              # libzip
              # zlib
            ]);

          # Run this command, only after creating the virtual environment
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install -r requirements.txt
          '';

          # Now we can execute any commands within the virtual environment.
          # This is optional and can be left out to run pip manually.
          postShellHook = ''
            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH
          '';
        };
      };
    };
}
