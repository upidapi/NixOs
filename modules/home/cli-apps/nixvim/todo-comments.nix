{
  programs.nixvim.plugins.todo-comments = {
    enable = true;

    guiStyle.fg = "BOLD";

    colors = {
      error = ["DiagnosticError" "ErrorMsg" "#DC2626"];
      warning = ["DiagnosticWarn" "WarningMsg" "#FBBF24"];
      info = ["DiagnosticInfo" "#2563EB"];
      hint = ["DiagnosticHint" "#10B981"];
      default = ["Identifier" "#7C3AED"];
      test = ["Identifier" "#FF00FF"];
    };

    highlight = {
      multiline = true; # enable multine todo comments

      # only continue comment if folowing line is indented
      multilinePattern = "^ "; # lua pattern to match the next multiline from the start of the matched keyword

      # multiline_context = 10; # extra lines that will be re-evaluated when changing a line
      before = ""; # "fg" or "bg" or empty
      keyword = "wide"; # "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
      after = "fg"; # "fg" or "bg" or empty
      # pattern = ''.*<(KEYWORDS)\s*:''; # pattern or table of patterns, used for highlighting (vim regex)
      commentsOnly = true; # uses treesitter to match keywords in comments only
      maxLineLen = 1000; # ignore lines longer than this
      # exclude = []; # list of file types to exclude highlighting
    };

    signs = false;

    keywords = {
      FIX = {
        icon = " "; # Icon used for the sign, and in search results.
        color = "error"; # Can be a hex color, or a named color.
        alt = ["FIXME" "BUG" "FIXIT" "ISSUE"]; # A set of other keywords that all map to this FIX keywords.
      };
      TODO = {
        icon = " ";
        color = "#2563EB";
        alt = ["todo"];
      };
      HACK = {
        icon = " "; # 󰈸 
        color = "warning";
      };
      WARN = {
        icon = " ";
        color = "warning";
        alt = [
          "WARNING"
          "XXX"
        ];
      };
      PERF = {
        icon = "󰅒 ";
        alt = [
          "OPTIM"
          "PERFORMANCE"
          "OPTIMIZE"
        ];
      };
      NOTE = {
        icon = "󰍩 ";
        color = "hint";
        alt = [
          "INFO"
        ];
      };
      /*
         TEST = {
        icon = "⏲ ";
        color = "test";
        alt = [
          "TESTING"
          "PASSED"
          "FAILED"
        ];
      };
      */
    };
  };
}
