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
        txt_color = "\033[0;34m"
        end_color = "\033[0m"

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


        # goto where the nix configs are
        cd $nixFlakeDir # > /dev/null

        # if files arn't added to git then nix simply ignores them
        git add --all

        # formatt code
        echo -e "$txt_color-----------------Formatting Files---------------------$end_color"
        alejandra . || true


        # show git diff
        echo -e "\n\nFile Diff:"
        git --no-pager diff

        # rebuild ignore everything except errors
        echo -e "\n\nRebuilding NixOS... (profile: $1)"
        # if this fails dont commit
        sudo nixos-rebuild switch --flake ".#$1" || exit 1


        # comit changes
        echo -e "\n\n$txt_color-----------------Commiting changes--------------------$end_color"

        # -am := add all staged changes, and a msg for the commit
        gen=$(nixos-rebuild list-generations | grep current)
        git commit -am "$2 ($gen)" #  --author="upidapi <videw@icloud.com>"


        echo -e "\n\n$txt_color--------------Pushing code to github------------------$end_color"
        # todo put this in sops
        # pat="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"
        # git push https://$pat@github.com/upidapi/NixOs.git main


        # popd > /dev/null

        echo -e "\n\nSuccessfully applied nixos configuration changes"
      '')
    ];
  };
}
