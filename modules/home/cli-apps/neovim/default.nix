{
  config,
  inputs,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (builtins) toString path;
  inherit (mlib) mkEnableOpt disable;

  inherit (lib) mkIf;
  cfg = config.modules.home.cli-apps.neovim;
  inherit (import ./lib.nix lib) listToLuaTable;
in {
  imports = [
    inputs.mnw.homeManagerModules.mnw
  ];

  options.modules.home.cli-apps.neovim =
    mkEnableOpt "enables my neovim config";

  # you can run it with
  # >>> nix run /persist/nixos#mnw -- file.txt
  # or as a env
  # >>> nix develop /persist/nixos#mnw -c bash -c "nvim file.txt; exit"

  config = mkIf cfg.enable {
    home = {
      sessionVariables = {EDITOR = "nvim";};
      file.".config/ruff/pyproject.toml" = {source = ./cfg-files/ruff.toml;};
    };

    programs.mnw = {
      enable = true;

      neovim = pkgs.neovim-unwrapped;

      desktopEntry = false;

      providers = {
        python3 = disable;
        nodeJs = disable;
        ruby = disable;
      };

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

        # ts / js
        typescript

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

        # terraform
        terraform-lsp
        terraform-ls # the future

        # go
        gofumpt
        golangci-lint
        gopls

        # sql
        sqls
        sqlfluff
        sqlcmd

        # java
        java-language-server
        google-java-format
        checkstyle

        # xml
        lemminx

        # php
        phpactor
        php # includes the linter
        # php84Packages.php-cs-fixer # broken

        # c#
        csharp-ls

        # c/cpp
        clang-tools
        gdb
        lldb
        vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb - debugger
        python312Packages.six

        # powershell
        powershell-editor-services

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
        nodejs

        luajitPackages.luacheck
      ];

      extraLuaPackages = ps:
        (with ps; [
          # for neorg
          lua-utils-nvim
          pathlib-nvim

          cjson
        ])
        ++ (with pkgs.luajitPackages; [
          magick # for image nvim
        ]);

      # nix-shell -p vimPlugins.nvim-treesitter-parsers.
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

              sql

              terraform

              powershell

              # norg # removed from nixpkgs?
              markdown
              markdown_inline
              typst

              regex

              javascript # includes jsx?
              typescript
              tsx
              svelte

              html
              css

              json
              yaml
              toml
              xml
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

        # vim-dadbod # DB client
        (pkgs.vimUtils.buildVimPlugin {
          pname = "vim-dadbod";
          version = "2025-04-29";
          src = pkgs.fetchFromGitHub {
            owner = "tpope";
            repo = "vim-dadbod";
            rev = "fa31d0ffeebaa59cf97a81e7f92194cced54a13f";
            sha256 = "sha256-2KVsKLxXq0/DThx1n4LnVz9cMuiOOO87dayeD5UPnoI=";
          };
          meta.homepage = "https://github.com/tpope/vim-dadbod/";
        })
        # vim-dadbod-completion # DB completion
        # vim-dadbod-ui # DB UI
        nvim-dbee

        cellular-automaton-nvim
        toggleterm-nvim
        nvim-web-devicons # project-nvim
        project-nvim # dep: plenary-nvim
        telescope-nvim

        # ai
        avante-nvim

        # provide extra text targets
        targets-vim
        nvim-surround

        (pkgs.vimUtils.buildVimPlugin {
          pname = "perfanno-nvim";
          version = "git";
          src = inputs.perfanno-nvim;
        })

        image-nvim

        (pkgs.vimUtils.buildVimPlugin {
          name = "img-clip";
          src = inputs.plugin-img-clip;
        })

        diffview-nvim
        vim-fugitive

        friendly-snippets
        luasnip

        codesnap-nvim

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

        # yaml
        SchemaStore-nvim

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
