{
  config,
  osConfig,
  lib,
  pkgs,
  inputs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.scripts.regen-nixos;
in {
  options.modules.home.scripts.regen-nixos =
    mkEnableOpt
    "Whether or not to add the regen-nixos command";

  config = mkIf cfg.enable {
    home.packages = [
      # used to formatt nix code
      inputs.alejandra.defaultPackage.${pkgs.system}
      # gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons

      (pkgs.writeShellScriptBin "regen-nixos" ''
        nixFlakeDir=${osConfig.modules.nixos.core.nixos-cfg-path}

        # make sure is root
        # if [ "$EUID" -ne 0 ]
        #   then echo "This requires root to run"
        #   exit
        # fi

        # make sure that user has selected a profile
        # for example "deafult"
        if [ $# -eq 0 ]
          then echo "NixOs profile not supplied"
          exit
        fi

        # make sure that we have a commit msg
        # for example "firefox is now in dark mode"
        if [ $# -eq 1 ]
          then echo "Generation note / msg not supplied"
          exit
        fi


        repeat() {
          for i in $(seq $1); do echo -n "$2"; done
        }

        # this is dumb, (its just practice)
        raw_print() {
          color="$2"
          color+="m"
          txt_color="\033[0;$color"
          end_color="\033[0m"

          txt="$1"
          tot_len=80
          padding=$(($tot_len - $(expr length "$txt")))
          raw_side=$((padding / 2))
          rounded=$(awk 'BEGIN { printf "%.0f", '"$raw_side"' }')

          echo -ne "$txt_color"
          repeat $rounded "$3"
          echo -n $txt
          repeat $((padding - rounded)) "$3"
          echo -e "$end_color"
        }

        print_action() {
          echo ""
          echo ""
          raw_print "$1" "33" "-"
        }

        # goto where the nix configs are
        cd $nixFlakeDir # > /dev/null

        # if files arn't added to git then nix simply ignores them
        git add --all

        # formatt code
        print_action "Formatting Files"

        alejandra . || true


        # show git diff
        print_action "Git Diff"
        git --no-pager diff

        # rebuild ignore everything except errors
        print_action "Rebuilding NixOS... (profile: $1)"
        # if this fails dont commit
        ret=sudo nixos-rebuild switch --flake ".#$1"
        if ! $ret; then
          # make sure that i dont miss it
          raw_print "" "41" " "
          raw_print "" "41" " "
          raw_print "Nixos Rebild Failed" "41" " "
          raw_print "" "41" " "
          raw_print "" "41" " "
          exit 1
        fi


        # comit changes
        print_action "Commiting changes"
        # -am := add all staged changes, and a msg for the commit
        gen=$(
          sudo nix-env \
            --list-generations \
            --profile /nix/var/nix/profiles/system \
          | grep -Po ".*(?=[(]current[)])" \
          | xargs
        )
        commit_msg="$2 (gen: $gen)"
        echo "commit msg:  $commit_msg"
        echo ""

        git commit -am "$commit_msg"

        print_action "Pushing code to github"
        # todo put this in sops
        pat="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"
        git push https://$pat@github.com/upidapi/NixOs.git main


        # popd > /dev/null

        echo ""
        echo ""
        raw_print  "Successfully applied nixos configuration changes" "32" "-"
      '')
    ];
  };
}
