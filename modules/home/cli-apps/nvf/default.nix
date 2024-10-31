# 95% of this file is directly copied from raf
# the rest is based on it
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
  cfg = config.modules.home.cli-apps.nvf;
in {
  imports = [
    inputs.nvf.homeManagerModules.default
    ./config.nix
  ];

  options.modules.home.cli-apps.nvf =
    mkEnableOpt "enables nvf a neovim distro powerd by nix";

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      enableManpages = true;

      defaultEditor = true;

      settings.vim = {
        package = pkgs.neovim-unwrapped;

        viAlias = false;
        vimAlias = false;

        # vi
        # vim.globals can be used to set vim.g.<name>

        # defaults
        withNodeJs = false;
        withPython3 = true;
        withRuby = false;

        preventJunkFiles = true;
        useSystemClipboard = true;

        enableLuaLoader = true;
        enableEditorconfig = true;

        debugMode = {
          enable = false;
          level = 16;
          logFile = "/tmp/nvim.log";
        };

        additionalRuntimePaths = [
          (path {
            name = "nvim-runtime";
            path = toString ./runtime;
          })
        ];

        # NOTE: luaConfigPre and luaConfigPost override the
        #  values internally

        # include this directory (/nvf) in the lua path
        # so that we can use it like we would normally
        luaConfigPost = ''
          -- Add a debug "option" so that we can avoid running
          -- the "built" in init if needed, for debugging
          if not vim.env.NVF_NO_LOAD_INIT then
              package.path = package.path .. ";" .. "${./.}/?.lua"
              require("lua.init")
          end
        '';

        # use the following cmd to recreate the vim dirtytalk plugin
        /*
        git clone https://github.com/psliwka/vim-dirtytalk.git
        cat vim-dirtytalk/wordlists/* > programing.words


        # in nvim
        :mkspell /persist/nixos/modules/home/cli-apps/nvf/runtime/spell/prog ~/programing.words
        */

        # (this can probable be automated)

        # recreate the add.spl file
        /*
        cd $NIXOS_CONFIG_PATH/modules/home/cli-apps/nvf/runtime/spell/ | mkspell! en.utf-8.add.spl en.utf-8.add
        */

        # notashelf
        # additional lua configuration that I can append or, to be more
        # precise, randomly inject into the lua configuration of my Neovim
        # configuration wrapper. This is recursively read from the lua
        # directory, so we do not need to use require
        luaConfigRC = let
          spellFile = path {
            name = "nvf-en.utf-8.add";
            path = ./runtime/spell/en.utf-8.add;
          };
        in {
          spell = "vim.o.spellfile = \"${spellFile}\"";
        };
      };
    };
  };
}
