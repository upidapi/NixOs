{
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    functionArgs
    intersectAttrs
    length
    optional
    ;
in {
  # writeShellApplication with support for completions
  writeShellApplicationCompletions = {
    name,
    bashCompletion ? null,
    zshCompletion ? null,
    fishCompletion ? null,
    ...
  } @ shellArgs: let
    inherit (pkgs) writeShellApplication writeTextFile symlinkJoin;
    # get the needed arguments for writeShellApplication
    app = writeShellApplication (intersectAttrs (functionArgs writeShellApplication) shellArgs);
    completions =
      optional (bashCompletion != null) (writeTextFile {
        name = "${name}.bash";
        destination = "/share/bash-completion/completions/${name}.bash";
        text = bashCompletion;
      })
      ++ optional (zshCompletion != null) (writeTextFile {
        name = "${name}.zsh";
        destination = "/share/zsh/site-functions/_${name}";
        text = zshCompletion;
      })
      ++ optional (fishCompletion != null) (writeTextFile {
        name = "${name}.fish";
        destination = "/share/fish/vendor_completions.d/${name}.fish";
        text = fishCompletion;
      });
  in
    if length completions == 0
    then app
    else
      symlinkJoin {
        inherit name;
        inherit (app) meta;
        paths = [app] ++ completions;
      };
}
