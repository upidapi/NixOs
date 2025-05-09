# poetry run python main.py
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
        # system,
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
          # postInstall = let
          #   argcomplete =
          #     pkgs.lib.getExe'
          #     pkgs.python3.pkgs.argcomplete
          #     "register-python-argcomplete";
          # in ''
          #   wrapProgram "$out/bin/default" \
          #     --prefix PATH : ${pkgs.lib.makeBinPath deps}
          #
          #   installShellCompletion --cmd ${
          #     "the name of cmd"
          #     /*
          #     todo
          #     */
          #   } \
          #     --bash <(${argcomplete} --shell bash dev-shell) \
          #     --zsh <(${argcomplete} --shell zsh dev-shell) \
          #     --fish <(${argcomplete} --shell fish dev-shell)
          # '';
          #
          # nativeBuildInputs = with pkgs; [
          #   installShellFiles
          # ];

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

        devShells.default = pkgs.mkShellNoCC {
          # you have to reload the env to make the pkgs show up
          name = "poetry-env";
          packages = with pkgs;
            [
              (mkPoetryEnv {
                projectDir = self;
                # seams to fix a lot of module issues,
                # why is this not the this the default?
                preferWheels = true;
              })
              poetry
            ]
            ++ deps;
        };
      };
    };
}
