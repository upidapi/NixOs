{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.obsidian;
in {
  options.modules.home.apps.obsidian = mkEnableOpt "";

  config = mkIf cfg.enable {
    programs.obsidian = {
      enable = true;
      defaultSettings = {
        app = {
          vimMode = true;
        };
        corePlugins = [
          "file-explorer"
          "global-search"
          "switcher"
          "graph"
          "backlink"
          "canvas"
          "outgoing-link"
          "tag-pane"
          "properties"
          "page-preview"
          "daily-notes"
          "templates"
          "note-composer"
          "command-palette"
          "slash-command"
          "editor-status"
          "bookmarks"
          "markdown-importer"
          "zk-prefixer"
          "random-note"
          "outline"
          "word-count"
          "slides"
          "audio-recorder"
          "workspaces"
          "file-recovery"
          "publish"
          "sync"
          "webviewer"
        ];
      };
    };
  };
}
