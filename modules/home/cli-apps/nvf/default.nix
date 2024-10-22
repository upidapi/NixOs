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
  inherit (builtins) filter map toString path;
  inherit (inputs.nvf.lib.nvim.dag) entryBefore;
  inherit (my_lib.opt) mkEnableOpt;

  inherit (lib.attrsets) genAttrs;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib) mkIf;
  inherit (lib.strings) hasSuffix fileContents;
  cfg = config.modules.home.cli-apps.nvf;
in {
  imports = [
    inputs.nvf.homeManagerModules.default
    ./config
    ./modules
  ];

  # TODO: move away from the nvf neovim config stuff and just use lua directly
  #  basically use it as a package manager, and for not much else
  #  might go as far as to switch to mnw

  # TODO: might make this into a flake and consume it to make quick iteration
  #  much easier. Its annoying having to rebuild the system just for a
  #  neovim setting

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
        withPython3 = false;
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

          # get the name of each lua file in the lua directory, where setting
          # files reside and import them recursively
          configPaths =
            filter
            (hasSuffix ".lua")
            (map toString (listFilesRecursive ./lua));

          # generates a key-value pair that looks roughly as follows:
          #  `<filePath> = entryAnywhere ''<contents of filePath>''`
          # which is expected by nvf's modified DAG library
          luaConfig = genAttrs configPaths (file:
            entryBefore ["luaScript"] ''
              ${fileContents file}
            '');
        in
          luaConfig // {spell = "vim.o.spellfile = \"${spellFile}\"";};
      };
    };
  };
}
