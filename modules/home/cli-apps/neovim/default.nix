{
  config,
  inputs,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (builtins) toString path;
  inherit (my_lib.opt) mkEnableOpt;

  inherit (lib) mkIf;
  cfg = config.modules.home.cli-apps.neovim;
  inherit (import ./lib.nix lib) listToLuaTable;
in {
  imports = [
    inputs.mnw.homeManagerModules.mnw
  ];

  options.modules.home.cli-apps.neovim =
    mkEnableOpt "enables my neovim config";

  config = mkIf cfg.enable {
    home.sessionVariables = {EDITOR = "nvim";};

    programs.mnw = {
      enable = true;

      neovim = pkgs.neovim-unwrapped;

      desktopEntry = false;

      withNodeJs = false;
      withPython3 = true;
      withRuby = false;

      viAlias = false;
      vimAlias = false;

      initLua = let
        additionalRuntimePaths = [
          (path {
            name = "nvim-runtime";
            path = toString ./runtime;
          })
        ];

        pythonDebugpy = pkgs.python3.withPackages (ps: with ps; [debugpy]);
        # a file to passthrough values to the lua config
        passthrough = pkgs.writeTextDir "passthrough.lua" ''
          local M = {}

          M.dap = {
              python = "${pythonDebugpy}/bin/python3"
          }

          return M
        '';
      in ''
        -- added as a fallback
        -- set in the lua cfg if NIXOS_CONFIG_PATH is set
        vim.opt.runtimepath:append(${listToLuaTable additionalRuntimePaths})

        -- Add a debug "option" so that we can avoid running
        -- the "built" in init if needed, for debugging
        if not vim.env.NEOVIM_NO_LOAD_INIT then
            package.path = package.path
              .. ";${./.}/?.lua"
              .. ";${./.}/?/init.lua"
              .. ";${passthrough}/?.lua"
              .. ";${passthrough}/?/init.lua"

            require("lua.init")
        end
      '';

      extraBinPath = with pkgs; [
        fd # used by treesitter

        # for image nvim
        imagemagick
        curl # (Remote images)
        ueberzugpp

        # nix
        nixd
        # nixfmt
        nixfmt-rfc-style
        nixpkgs-fmt
        statix
        deadnix

        # python
        ruff
        pyright

        # nu
        nufmt # not needed?
        nushell # nu --lsp used for the lsp

        # bash
        bash-language-server
        shfmt
        shellcheck

        # go
        gofumpt
        golangci-lint
        gopls

        # java
        java-language-server
        google-java-format
        checkstyle

        # php
        phpactor
        php # includes the linter
        php.packages.php-cs-fixer

        # c#
        csharp-ls

        # c/cpp
        clang-tools
        gdb
        lldb
        vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb - debugger
        python312Packages.six

        # markdown
        markdownlint-cli2
        marksman

        # typst
        tinymist

        # rust
        clippy
        rustfmt
        rust-analyzer

        # lua
        lua-language-server
        stylua

        # css / html / json / eslint
        vscode-langservers-extracted
        eslint_d
        prettierd
        svelte-language-server

        tailwindcss-language-server

        yaml-language-server

        luajitPackages.luacheck
      ];

      extraLuaPackages = ps:
        with ps; [
          magick # for image nvim

          # for neorg
          lua-utils-nvim
          pathlib-nvim

          cjson
        ];

      # nix-shell -p vimPlugins.nvim-treesitter-parsers
      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (
          parsers:
            with parsers; [
              bash
              nu

              lua
              python
              nix

              c_sharp

              c
              cpp
              rust

              norg
              markdown
              markdown_inline
              typst

              regex

              javascript # also jsx
              typescript # also tsx
              svelte

              html
              css

              json
              yaml
              toml
            ]
        ))

        comment-nvim
        nvim-autopairs
        todo-comments-nvim
        tokyonight-nvim
        neo-tree-nvim
        # smartcolumn-nvim # inlined
        nvim-colorizer-lua
        indent-blankline-nvim
        highlight-undo-nvim

        nvim-treesitter

        cellular-automaton-nvim
        toggleterm-nvim
        nvim-web-devicons # project-nvim
        project-nvim # dep: plenary-nvim
        telescope-nvim

        # image-nvim
        # TODO: switch bask to the "image-nvim" pkgs when my pr merges
        #  https://github.com/3rd/image.nvim/pull/266
        (pkgs.neovimUtils.buildNeovimPlugin {
          pname = "image.nvim";
          version = "2024-11-10";
          src = pkgs.fetchFromGitHub {
            owner = "upidapi";
            repo = "image.nvim";
            rev = "6915dd057ed8a29d09db8495b8746a54073b028d";
            sha256 = "sha256-SgTr0AhlPMmGDKAFpaL+W/nK6zLmh/s+wGD5XcaMFyo=";
          };
          meta.homepage = "https://github.com/3rd/image.nvim/";
        })

        # (buildNeovimPlugin {
        #   pname = "image.nvim";
        #   version = "2024-11-10";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "3rd";
        #     repo = "image.nvim";
        #     rev = "7f61c1940a8b072ca47a28928d2375dc1e11f464";
        #     sha256 = "0fqnz4wpw7ab1j0y4zqafazjg6q0rc66n71awx4wbxilikca80ml";
        #   };
        #   meta.homepage = "https://github.com/3rd/image.nvim/";
        # })
        (pkgs.vimUtils.buildVimPlugin {
          name = "img-clip";
          src = inputs.plugin-img-clip;
        })

        diffview-nvim
        vim-fugitive

        friendly-snippets
        luasnip

        # the "colorizer" plugin is the vim version which is horribly slow
        nvim-colorizer-lua

        # completions
        blink-cmp
        blink-compat

        # lsp
        nvim-lspconfig
        lspsaga-nvim

        conform-nvim
        nvim-lint

        nvim-dap # dep: plenary
        nvim-dap-virtual-text
        nvim-dap-ui

        # ui
        nord-nvim
        noice-nvim
        lualine-nvim
        bufferline-nvim

        vim-bbye

        nvim-ufo

        auto-save-nvim
        guess-indent-nvim

        # lua
        lazydev-nvim
        neodev-nvim
        one-small-step-for-vimkind

        # typst
        typst-preview-nvim

        # markdown

        # python
        nvim-dap-python

        # rust
        rustaceanvim
        crates-nvim
        # might need rustfmt and clippy

        # ts
        typescript-tools-nvim
        nvim-ts-autotag

        # why does neorg have so many deps?!
        # start
        neorg
        neorg-telescope
        nui-nvim
        nvim-nio
        plenary-nvim
        # broken
        # (pkgs.vimUtils.buildVimPlugin {
        #   name = "neorg-interim-ls";
        #   src = inputs.plugin-neorg-interim-ls;
        # })
      ];
    };
  };
}
