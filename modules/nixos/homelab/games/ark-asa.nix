{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.games.ark-asa;

  root_dir = "/home/steam";
  # =============================================================================
  # SHARED SERVER SETTINGS
  # =============================================================================
  # Settings are organized by INI file and section.
  # Only keys defined here will be managed - everything else is preserved.
  # Files must already exist (created by ARK on first run).

  # GameUserSettings.ini settings
  gameUserSettings = {
    ServerSettings = {
      # -- Difficulty --
      DifficultyOffset = 1.0;
      OverrideOfficialDifficulty = 5.0; # Max wild dino level 150

      # -- Server Type --
      ServerPVE = "False"; # PvP mode
      ServerHardcore = "False";
      AllowThirdPersonPlayer = "True";
      ServerCrosshair = "True";
      ShowMapPlayerLocation = "True";
      ShowFloatingDamageText = "True";
      AllowHitMarkers = "True";
      EnablePvPGamma = "True"; # Allow gamma adjustment in PvP

      # -- XP & Harvesting --
      XPMultiplier = 3.0;
      HarvestAmountMultiplier = 2.0;
      HarvestHealthMultiplier = 1.0;
      ResourcesRespawnPeriodMultiplier = 0.25;

      # -- Taming --
      TamingSpeedMultiplier = 5.0;
      AllowRaidDinoFeeding = "False";

      # -- Dino Stats --
      DinoCharacterFoodDrainMultiplier = 1.0;
      DinoCharacterHealthRecoveryMultiplier = 1.0;
      DinoCharacterStaminaDrainMultiplier = 1.0;
      DinoDamageMultiplier = 1.0;
      DinoResistanceMultiplier = 1.0;

      # -- Player Stats --
      PlayerDamageMultiplier = 1.0;
      PlayerResistanceMultiplier = 1.0;
      PlayerCharacterFoodDrainMultiplier = 1.0;
      PlayerCharacterWaterDrainMultiplier = 1.0;
      PlayerCharacterHealthRecoveryMultiplier = 1.0;
      PlayerCharacterStaminaDrainMultiplier = 1.0;

      # -- Day/Night Cycle --
      DayCycleSpeedScale = 1.0;
      DayTimeSpeedScale = 1.0;
      NightTimeSpeedScale = 1.0;

      # -- Structures --
      StructureDamageMultiplier = 1.0;
      StructureResistanceMultiplier = 1.0;
      PerPlatformMaxStructuresMultiplier = 1.0;
      TheMaxStructuresInRange = 10500;
      DisableStructureDecayPvE = "True";
      OverrideStructurePlatformPrevention = "True";
      AllowIntegratedSPlusStructures = "True";

      # -- Quality of Life --
      AllowAnyoneBabyImprintCuddle = "True";
      AllowFlyerCarryPvE = "True";
      ForceAllowCaveFlyers = "True";
      PreventDiseases = "False";
      NonPermanentDiseases = "True";
      ItemStackSizeMultiplier = 5.0;

      # -- Cryopods --
      DisableCryopodFridgeRequirement = "True";
      DisableCryopodEnemyCheck = "True";
      AllowCryoFridgeOnSaddle = "True";
      EnableCryopodNerf = "False";
      EnableCryoSicknessPVP = "False";

      # -- Cluster/Transfers --
      NoTributeDownloads = "False";
      PreventDownloadSurvivors = "False";
      PreventDownloadItems = "False";
      PreventDownloadDinos = "False";

      # -- Offline Raid Protection --
      PreventOfflinePvP = "True"; # Structures/dinos invulnerable when tribe offline
      PreventOfflinePvPInterval = 900; # 15 min delay before ORP activates

      # -- Server Limits --
      MaxTamedDinos = 5000;
      KickIdlePlayersPeriod = 3600;
      AutoSavePeriodMinutes = 15;
    };

    "/Script/Engine.GameSession" = {
      MaxPlayers = 20;
    };

    # Cryo Sickness Protection mod - forces protection server-wide on vanilla cryopods
    CryoSicknessProtection = {
      bForceProtection = "True"; # Automatic server-wide, no player action needed
    };
  };

  # Game.ini settings
  gameIniSettings = {
    "/Script/ShooterGame.ShooterGameMode" = {
      # -- Breeding (20x speed with 12-min cuddles) --
      BabyImprintingStatScaleMultiplier = 2.0;
      BabyCuddleIntervalMultiplier = 0.025; # 12 minutes between cuddles
      BabyCuddleGracePeriodMultiplier = 2.0;
      BabyFoodConsumptionSpeedMultiplier = 1.0;
      EggHatchSpeedMultiplier = 20.0; # Match mature speed
      BabyMatureSpeedMultiplier = 20.0; # 20x faster maturation
      MatingIntervalMultiplier = 0.05; # 20x faster mating interval
      LayEggIntervalMultiplier = 0.5;
      BabyImprintAmountMultiplier = 3.0; # ~33% per cuddle (3 cuddles = 100%)

      # -- Harvesting --
      DinoHarvestingDamageMultiplier = 2.0;
      PlayerHarvestingDamageMultiplier = 1.0;

      # -- Loot & Crafting --
      SupplyCrateLootQualityMultiplier = 2.0;
      FishingLootQualityMultiplier = 2.0;
      CraftingSkillBonusMultiplier = 1.0;

      # -- Spoiling & Decay --
      GlobalSpoilingTimeMultiplier = 2.0;
      GlobalItemDecompositionTimeMultiplier = 2.0;
      GlobalCorpseDecompositionTimeMultiplier = 2.0;
      CropGrowthSpeedMultiplier = 2.0;
      CropDecaySpeedMultiplier = 1.0;

      # -- QoL --
      bAllowCustomRecipes = "True";
      bAllowUnlimitedRespecs = "True";
      bUseCorpseLocator = "True";
      bAllowSpeedLeveling = "True"; # Ground dino speed leveling
      bAllowFlyerSpeedLeveling = "True"; # Flyer speed (mod 937389 fixes this)
      MaxDifficulty = "True";

      # -- Player Stats Per Level --
      # Index: 0=Health 1=Stamina 2=Torpidity 3=Oxygen 4=Food 5=Water 6=Temp 7=Weight 8=Melee 9=Speed 10=Fortitude
      "PerLevelStatsMultiplier_Player[1]" = 2.0; # Stamina
      "PerLevelStatsMultiplier_Player[7]" = 3.0; # Weight
      "PerLevelStatsMultiplier_Player[10]" = 2.0; # Fortitude

      # -- Dino Stat Multipliers (per level) --
      # Index: 0=Health 1=Stamina 2=Torpidity 3=Oxygen 4=Food 5=Water 6=Temp 7=Weight 8=Melee 9=Speed 10=Fortitude
      # DEFAULTS: Health=0.09, Stamina=1, Weight=1, Melee=0.07, Speed=1
      "PerLevelStatsMultiplier_DinoTamed[0]" = 0.18; # Health (2x default)
      "PerLevelStatsMultiplier_DinoTamed[1]" = 2.0; # Stamina (2x default)
      "PerLevelStatsMultiplier_DinoTamed[7]" = 2.0; # Weight (2x default)
      "PerLevelStatsMultiplier_DinoTamed[8]" = 0.14; # Melee (2x default)
      "PerLevelStatsMultiplier_DinoTamed[9]" = 3.0; # Speed (3x default)
    };
  };

  # =============================================================================
  # PER-MAP OVERRIDES
  # =============================================================================

  mapOverrides = {
    island = {};
    scorched = {};
    aberration = {
      gameUserSettings = {
        ServerSettings = {
          ForceAllowCaveFlyers = "False";
        };
      };
    };
  };

  # =============================================================================
  # MODS & CLUSTER
  # =============================================================================
  mods = [
    "1195096" # Genetic Traits Mutator
    "1099220" # Better Traits (No-DLC TraitScanner and Storage)
    "929420" # Super Spyglass Plus
    "989002" # Cryo Sickness Protection - Auto server-wide, works on vanilla cryopods
    "935399" # Improved Egg Incubator - Auto incubation & mutation viewing
  ];
  modString = lib.concatStringsSep "," mods;
  clusterID = "y5YKVK4wfc4J";

  # =============================================================================
  # CONFIG SCRIPT GENERATION
  # =============================================================================

  # Deep merge settings with per-map overrides
  mergeSettings = base: override:
    lib.recursiveUpdate base override;

  getGameUserSettings = map:
    mergeSettings gameUserSettings (mapOverrides.${map}.gameUserSettings or {});

  getGameIniSettings = map:
    mergeSettings gameIniSettings (mapOverrides.${map}.gameIniSettings or {});

  # Generate crudini commands for a settings attrset
  # crudini --set FILE SECTION KEY VALUE
  mkCrudiniCommands = file: settings:
    lib.concatStringsSep "\n" (
      lib.flatten (
        lib.mapAttrsToList (
          section: keys:
            lib.mapAttrsToList (
              key: value: ''${pkgs.crudini}/bin/crudini --set "${file}" "${section}" "${key}" "${toString value}"''
            )
            keys
        )
        settings
      )
    );
  # mkCrudiniCommands2 = file: settings:
  #   lib.pipe settings [
  #     (lib.mapAttrsToList (
  #       s: ks:
  #         lib.mapAttrsToList (
  #           k: v: ''${pkgs.crudini}/bin/crudini --set "${file}" "${s}" "${k}" "${toString v}"''
  #         )
  #         ks
  #     ))
  #     lib.flatten
  #     (lib.concatStringsSep "\n")
  #   ];
  # mkCrudiniCommands3 = file: settings:
  #   lib.pipe settings [
  #     (lib.mapAttrsToList (s: ks: lib.mapAttrsToList (k: v: [s k v]) ks))
  #     lib.flatten
  #     (lib.concatStringsSep "\n")
  #   ];

  # Create the config sync script for a map
  mkConfigScript = serverMap: let
    configDir = "/srv/ark/${serverMap}/ShooterGame/Saved/Config/WindowsServer";
    gameUserSettingsFile = "${configDir}/GameUserSettings.ini";
    gameIniFile = "${configDir}/Game.ini";
  in
    pkgs.writeShellScript "ark-${serverMap}-config-sync" ''
      set -euo pipefail

      echo "=== ARK Config Sync: ${serverMap} ==="

      # GameUserSettings.ini must exist (created by ARK on first run)
      if [[ ! -f "${gameUserSettingsFile}" ]]; then
        echo "WARNING: ${gameUserSettingsFile} does not exist."
        echo "ARK needs to run once to create default configs."
        echo "Skipping config sync - server will start with defaults."
        exit 0
      fi

      # Game.ini is NOT auto-created by ASA - create it with proper header if missing
      if [[ ! -f "${gameIniFile}" ]]; then
        echo "Creating ${gameIniFile} (ASA does not auto-create this file)..."
        echo "[/script/shootergame.shootergamemode]" > "${gameIniFile}"
      fi

      echo "Applying managed settings to GameUserSettings.ini..."
      ${mkCrudiniCommands gameUserSettingsFile (getGameUserSettings serverMap)}

      echo "Applying managed settings to Game.ini..."
      ${mkCrudiniCommands gameIniFile (getGameIniSettings serverMap)}

      echo "Config sync complete for ${serverMap}"
    '';

  # =============================================================================
  # CONTAINER DEFINITION
  # =============================================================================

  mkArkServer = {
    serverMap,
    autoStart ? true,
  }: {
    image = "mschnitzer/asa-linux-server:latest";
    inherit autoStart;
    entrypoint = "/usr/bin/start_server";
    user = "gameserver";
    volumes = [
      "/var/lib/ark/${serverMap}:/home/gameserver/server-files:rw"
      "/var/lib/ark/steam/${serverMap}/steam:/home/gameserver/Steam:rw"
      "/var/lib/ark/steam/${serverMap}/steamcmd:/home/gameserver/steamcmd:rw"
      "/var/lib/ark/cluster:/home/gameserver/cluster-shared:rw"
      "/var/lib/ark/shared/PlayersJoinNoCheckList.txt:/home/gameserver/server-files/ShooterGame/Binaries/Win64/PlayersJoinNoCheckList.txt:ro"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environmentFiles = [config.sops.templates."ark-${serverMap}.env".path];
    extraOptions = ["--memory=14g" "--cpus=4" "--tty" "--network=host"];
  };
  # maps = ["island" "scorched" "aberration"];
in {
  # ARK: Survival Ascended Server Cluster Configuration
  options.modules.nixos.homelab.games.ark-asa = mkEnableOpt "";

  config = mkIf cfg.enable {
    sops.templates = let
      mkArgs = ls: kv: args:
        lib.pipe kv [
          (lib.mapAttrsToList (k: v: "${k}=${toString v}"))
          (v: ls ++ v)
          (lib.concatStringsSep "?")
          (v: [v] ++ args)
          (lib.concatStringsSep " ")
          (v: "ASA_START_PARAMS=${v}")
        ];
    in {
      "ark-island.env".content =
        mkArgs ["TheIsland" "listen"] {
          SessionName = "penis-o-atfc";
          ServerPassword = "ensdfasdi";
          ServerAdminPassword = "ensdfasdi";
          Port = 6807; # + 1 is used for raw trafik
          QueryPort = 6808;
          RCONPort = 6809;
          RCONEnabled = "True";
        } [
          "-WinLiveMaxPlayers=20"
          "-clusterid=${clusterID}"
          "-ClusterDirOverride=\"${root_dir}/cluster-shared\""
          "-NoTransferFromFiltering"
          "-NoBattlEye"
          "-AllowFlyerSpeedLeveling"
          "-mods=${modString}"
        ];
    };
    /*
    ASA_START_PARAMS=Aberration_WP?listen?SessionName=NA-G-Chat-Aberration?Port=7781?RCONPort=27022?RCONEnabled=True?ServerPassword=${config.sops.placeholder."ark/server-password"}?ServerAdminPassword=${config.sops.placeholder."ark/admin-password"} -WinLiveMaxPlayers=20 -clusterid=${clusterID} -ClusterDirOverride="/home/gameserver/cluster-shared" -NoTransferFromFiltering -NoBattlEye -AllowFlyerSpeedLeveling -mods=${modString}
    */

    # ===========================================================================
    # SHARED FILES
    # ===========================================================================
    # Ensure shared whitelist file exists for cluster-wide password bypass

    systemd.tmpfiles.rules = [
      "d /var/lib/ark/shared 0755 1000 1000 -"
      "f /var/lib/ark/shared/PlayersJoinNoCheckList.txt 0644 1000 1000 -"

      "d /var/lib/ark/cluster 0755 1000 1000 -"
      "d /var/lib/ark/island 0755 1000 1000 -"
      "d /var/lib/ark/steam/island/steam 0755 1000 1000 -"
      "d /var/lib/ark/steam/island/steamcmd 0755 1000 1000 -"
    ];

    # ===========================================================================
    # CONFIG SYNC SERVICES
    # ===========================================================================
    # These run before each container starts, applying only our managed settings.
    # If config files don't exist yet, they exit gracefully and let ARK create them.
    systemd.services = lib.listToAttrs (map (mapName: {
        name = "ark-${mapName}-config";
        value = {
          description = "Sync ARK ${mapName} server configuration";
          wantedBy = ["podman-ark-${mapName}.service"];
          before = ["podman-ark-${mapName}.service"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = mkConfigScript mapName;
          };
        };
      })
      ["island"]);

    # ===========================================================================
    # CONTAINERS
    # ===========================================================================
    # ARK servers can be re-enabled by removing the autoStart = false option from each container

    virtualisation.oci-containers.containers = {
      ark-island = mkArkServer {
        serverMap = "island";
        autoStart = true;
      };
      # ark-scorched = mkArkServer {
      #   serverMap = "scorched";
      #   autoStart = false;
      # };
      # ark-aberration = mkArkServer {
      #   serverMap = "aberration";
      #   autoStart = false;
      # };
    };
  };
}
