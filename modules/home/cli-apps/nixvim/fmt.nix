{
  inputs,
  pkgs,
  ...
}: {
  # the core of this is "barrowed" (stolen) from
  # "https://github.com/ErrorNoInternet/configuration.nix/blob/0c074279a82089fb949a2b9f7e92bb1daca1d3e1/home/programs/terminal/neovim/formatting.nix"

  programs.nixvim = {
    extraPackages = with pkgs; [
      inputs.alejandra.defaultPackage.${pkgs.system}
      black
      clang-tools
      isort
      taplo
    ];

    plugins.conform-nvim = {
      enable = true;

      extraOptions = {
        timeout_ms = 10000; # what is this
        lsp_fallback = true;
      };

      # formatOnSave = true;

      formattersByFt = {
        c = ["clang_format"];
        cpp = ["clang_format"];
        # go = ["gofmt"];
        nix = ["alejandra"];
        python = ["isort" "black"];
        rust = ["rustfmt"];
        toml = ["taplo"];
      };
    };

    keymaps = [
      {
        mode = "n";
        options.silent = true;
        key = "<F3>";
        action = ":lua require('conform').format()<CR>";
      }
      {
        mode = "i";
        options.silent = true;
        key = "<F3>";
        action = "<esc>:lua require('conform').format()<CR>";
      }
    ];
  };
}
