{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.media.dec;
in {
  options.modules.nixos.homelab.media.dec = mkEnableOpt "";

  config = let
    postStart = ''
      ${
        makeCurlScript "sonarr-curl-script"
        ''
          silent
          show-error
          parallel
        ''
        ''
          header = "X-Api-Key: ${sonarr.apiKey}"
          header = "Content-Type: application/json"
          retry = 3
          retry-connrefused
        ''
        (
          let
            naming = ''
              fail-with-body
              url = "http://localhost:${sonarr.port}/api/v3/config/naming/1"
              request = "PUT"
              data = "@${
                jsonFormat.generate "naming.json" {
                  id = 1;
                  renameEpisodes = true;
                  replaceIllegalCharacters = true;
                  colonReplacementFormat = 0;
                  customColonReplacementFormat = "";
                  multiEpisodeStyle = 0;
                  standardEpisodeFormat = "{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Title} {MediaInfo VideoCodec}";
                  dailyEpisodeFormat = "{Series Title} - {Air-Date} - {Episode Title} {Quality Title} {MediaInfo VideoCodec}";
                  animeEpisodeFormat = "{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Title} {MediaInfo VideoCodec}";
                  seriesFolderFormat = "{Series Title}";
                  seasonFolderFormat = "Season {season}";
                  specialsFolderFormat = "Specials";
                }
              }"
            '';
          in
            [
              # PUT naming twice - first PUT doesn't work???
              naming
              naming
              ''
                fail-with-body
                url = "http://localhost:${sonarr.port}/api/v3/config/mediamanagement/1"
                request = "PUT"
                data = "@${
                  jsonFormat.generate "mediamanagement.json" {
                    id = 1;
                    importExtraFiles = true;
                    extraFileExtensions = "srt";
                    deleteEmptyFolders = true;

                    # GUI defaults
                    copyUsingHardlinks = true;
                    recycleBinCleanupDays = 7;
                    minimumFreeSpaceWhenImporting = 100;
                    enableMediaInfo = true;
                  }
                }"
              ''
            ]
            ++ (builtins.map (folder: ''
                url = "http://localhost:${sonarr.port}/api/v3/rootfolder"
                request = "POST"
                data = "@${jsonFormat.generate "rootfolder.json" folder}"
              '')
              sonarr.rootFolders)
            ++ (builtins.map (name: ''
              url = "http://localhost:${sonarr.port}/api/v3/downloadclient"
              request = "POST"
              data = "@${
                jsonFormat.generate "${name}.json" (
                  {
                    inherit name;
                    enable = true;
                    removeCompletedDownloads = true;
                    removeFailedDownloads = true;
                  }
                  // makeArrConfig sonarr.downloadClients.${name}
                )
              }"
            '') (builtins.attrNames sonarr.downloadClients))
        )
      }
    '';

    makeCurlScript = name: options: ctx: requests:
      pkgs.writeTextFile {
        inherit name;
        executable = true;
        text = ''
          #!${pkgs.curl}/bin/curl -K
          ${options}
          ${builtins.concatStringsSep "\nnext\n" (builtins.map (request: "${ctx}\n${request}") requests)}
        '';
      };
    x = pkgs.writeText "curl" ''
      API_KEY="$(cat ${1})"

      curl \
        --silent \
        --show-error \
        --parallel \
        --retry 3 \
        --retry-connrefused \
        --url 123 \
        -H "X-Api-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "${"data"}"
    '';
  in
    mkIf cfg.enable {
    };
}
