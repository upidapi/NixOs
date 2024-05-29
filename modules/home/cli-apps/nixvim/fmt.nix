{
  inputs,
  pkgs,
  ...
}: {
  # the core of this is "barrowed" (stolen) from
  # "https://github.com/ErrorNoInternet/configuration.nix/blob/0c074279a82089fb949a2b9f7e92bb1daca1d3e1/home/programs/terminal/neovim/formatting.nix"

  programs.nixvim = {
    extraPackages =
      (with pkgs; [
        clang-tools
        taplo

        black
        isort
        ruff

        codespell
        # trimWhitespace
      ])
      ++ [
        inputs.alejandra.defaultPackage.${pkgs.system}
      ];

    plugins.conform-nvim = {
      enable = true;

      /*
         extraOptions = {
        timeout_ms = 10000; # what is this
        lsp_fallback = true;
      };
      */
      formatOnSave = {
        lspFallback = true;
        timeoutMs = 500;
      };

      formatAfterSave = {
        lspFallback = true;
      };

      formattersByFt = {
        c = ["clang_format"];
        cpp = ["clang_format"];
        # go = ["gofmt"];
        nix = ["alejandra"];
        python = ["ruff-fmt" "ruff-lint"];
        rust = ["rustfmt"];
        toml = ["taplo"];
        "*" = ["codespell"];
        # :w"_" = ["trimWhitespace"];
      };

      formatters = {
        "ruff-fmt" = {
          command = "ruff";
          args = [
            "format"
            "--config"
            "${./config/ruff.toml}"
            "--force-exclude"
            "--stdin-filename"
            "$FILENAME"
            "-"
          ];
          stdin = true;
        };
        "ruff-lint" = {
          command = "ruff";
          args = [
            "check"
            "--config"
            "${./config/ruff.toml}"
            "--fix"
            "--force-exclude"
            "--stdin-filename"
            "$FILENAME"
            "-"
          ];
          stdin = true;
        };
      };
    };

    keymaps = [
    ];
  };
}
