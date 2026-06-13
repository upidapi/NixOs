{
  config,
  pkgs,
  lib,
  self',
  ...
}: let
  cfg = config.services.jfa-go;
  package = self'.packages.jfa-go;

  defaults = {
    first_run = false;

    updates = {
      enabled = true;
      channel = "";
    };

    jellyfin = {
      username = "username";
      password = "password";
      server = "http://jellyfin.local:8096";
      public_server = "";
      client = "jfa-go";
      cache_timeout = 30;
      web_cache_async_timeout = 1;
      web_cache_sync_timeout = 10;
      type = "jellyfin";
      substitute_jellyfin_strings = "";
    };

    ui = {
      language-form = "en-us";
      language-admin = "en-us";
      theme = "Jellyfin (Dark)";
      host = "0.0.0.0";
      port = 8056;
      jellyfin_login = true;
      admin_only = true;
      allow_all = false;
      username = "your username";
      password = "your password";
      email = "example@example.com";
      debug = false;
      contact_message = "Need help? contact me.";
      help_message = "Enter your details to create an account.";
      success_message = "Your account has been created. Click below to continue to Jellyfin.";
      jfa_url = "";
      use_proxy_host = false;
      url_base = "";
      redirect_url = "";
      auto_redirect = false;
      login_appearance = "clear";
    };

    url_paths = {
      admin = "";
      user_page = "/my/account";
      form = "/invite";
    };

    advanced = {
      log_ips = false;
      log_ips_users = false;
      tls = false;
      tls_port = 8057;
      tls_cert = "";
      tls_key = "";
      auth_retry_count = 6;
      auth_retry_gap = 10;
      proxy = false;
      proxy_protocol = "http";
      proxy_address = "";
      proxy_user = "";
      proxy_password = "";
      value_log_size = 256;
      debug_log_emails = "none";
      debug_log_discord = "none";
      debug_log_telegram = "none";
      debug_log_matrix = "none";
      debug_log_invites = "none";
      debug_log_announcements = "none";
      debug_log_expiries = "none";
      debug_log_profiles = "none";
      debug_log_custom_content = "none";
    };

    activity_log = {
      keep_n_records = 1000;
      delete_after_days = 90;
    };

    captcha = {
      enabled = false;
      recaptcha = false;
      recaptcha_site_key = "";
      recaptcha_secret_key = "";
      recaptcha_hostname = "";
    };

    user_page = {
      enabled = true;
      show_link = true;
      referrals = true;
      allow_pwr_username = true;
      allow_pwr_email = true;
      allow_pwr_contact_method = true;
    };

    password_validation = {
      enabled = true;
      min_length = 8;
      upper = 1;
      lower = 0;
      number = 1;
      special = 0;
    };

    messages = {
      enabled = true;
      use_24h = true;
      date_format = "%d/%m/%y";
      message = "Need help? contact me.";
    };

    email = {
      language = "en-us";
      collect = true;
      required = false;
      require_unique = false;
      no_username = false;
      method = "smtp";
      address = "jellyfin@jellyf.in";
      from = "Jellyfin";
      plaintext = false;
    };

    mailgun = {
      api_url = "https://api.mailgun.net...";
      api_key = "your api key";
    };

    smtp = {
      username = "";
      encryption = "starttls";
      server = "smtp.jellyf.in";
      port = 465;
      password = "smtp password";
      hello_hostname = "localhost";
      ssl_cert = "";
      cert_validation = true;
      auth_type = 4;
    };

    discord = {
      enabled = false;
      show_on_reg = true;
      required = false;
      require_unique = false;
      token = "";
      start_command = "start";
      channel = "";
      provide_invite = false;
      invite_channel = "";
      apply_role = "";
      disable_enable_role = false;
      language = "en-us";
    };

    telegram = {
      enabled = false;
      show_on_reg = true;
      required = false;
      require_unique = false;
      token = "";
      language = "en-us";
    };

    matrix = {
      enabled = false;
      show_on_reg = true;
      required = false;
      require_unique = false;
      homeserver = "";
      token = "";
      user_id = "";
      topic = "Jellyfin notifications";
      language = "en-us";
      encryption = true;
    };

    password_resets = {
      enabled = true;
      watch_directory = "/path/to/jellyfin";
      link_reset = false;
      set_password = false;
      url_base = "";
      language = "en-us";
      email_html = "jfa-go:password-reset.html";
      email_text = "jfa-go:password-reset.txt";
      subject = "";
    };

    invite_emails = {
      enabled = false;
      email_html = "jfa-go:invite-email.html";
      email_text = "jfa-go:invite-email.txt";
      subject = "";
      url_base = "";
    };

    template_email = {
      email_html = "jfa-go:template.html";
      email_text = "jfa-go:template.txt";
    };

    notifications = {
      enabled = false;
      expiry_html = "jfa-go:expired.html";
      expiry_text = "jfa-go:expired.txt";
      created_html = "jfa-go:created.html";
      created_text = "jfa-go:created.txt";
    };

    ombi = {
      enabled = false;
      server = "";
      api_key = "";
    };

    jellyseerr = {
      enabled = false;
      server = "";
      api_key = "";
      import_existing = false;
    };

    backups = {
      enabled = false;
      path = "";
      every_n_minutes = 1440;
      keep_n_backups = 20;
      keep_previous_version_backup = true;
    };

    welcome_email = {
      enabled = false;
      subject = "";
      email_html = "jfa-go:welcome.html";
      email_text = "jfa-go:welcome.txt";
    };

    email_confirmation = {
      enabled = false;
      subject = "";
      email_html = "jfa-go:confirmation.html";
      email_text = "jfa-go:confirmation.txt";
    };

    user_expiry = {
      behaviour = "disable_user";
      delete_expired_after_days = 0;
      send_email = true;
      send_reminder_n_days_before = "";
      subject = "";
      reminder_subject = "";
      adjustment_subject = "";
      email_html = "jfa-go:user-expired.html";
      email_text = "jfa-go:user-expired.txt";
      adjustment_email_html = "jfa-go:expiry-adjusted.html";
      adjustment_email_text = "jfa-go:expiry-adjusted.txt";
      reminder_email_html = "jfa-go:expiry-reminder.html";
      reminder_email_text = "jfa-go:expiry-reminder.txt";
    };

    disable_enable = {
      subject_disabled = "";
      subject_enabled = "";
      disabled_html = "jfa-go:deleted.html";
      disabled_text = "jfa-go:deleted.txt";
      enabled_html = "jfa-go:deleted.html";
      enabled_text = "jfa-go:deleted.txt";
    };

    deletion = {
      subject = "";
      email_html = "jfa-go:deleted.html";
      email_text = "jfa-go:deleted.txt";
    };

    webhooks = {
      created = "";
    };

    files = {
      invites = "";
      password_resets = "";
      emails = "";
      users = "";
      ombi_template = "";
      user_profiles = "";
      html_templates = "";
      lang_files = "";
      custom_emails = "";
      custom_user_page_content = "";
      telegram_users = "";
      matrix_users = "";
      matrix_sql = "";
      discord_users = "";
      announcements = "";
    };
  };
in {
  options = {
    services.jfa-go = {
      enable = lib.mkEnableOption "jfa-go";

      # package = lib.mkPackageOption pkgs "jfa-go" {};

      user = lib.mkOption {
        type = lib.types.str;
        default = "jfa-go";
        description = "User account under which jfa-go runs.";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "jfa-go";
        description = "Group under which jfa-go runs.";
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/jfa-go";
        description = ''
          The directory where jfa-go stores its data files. This directory
          will be created if it does not exist.
        '';
      };

      cfgFileContent = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      cfgFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf lib.types.anything;
        };
        default = {};
      };

      apiSettings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
        };
        default = {};
        example = {
          "emails/UserPage".content = "hello";
        };
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = ''
          Path to environment files that contain environment variables to pass
          to the jfa-go service, for the purpose of passing secrets to the
          service.
        '';
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    # NOTE: a hatch for sops templates
    services.jfa-go.cfgFileContent = let
      toIni = cfg: let
        isSection = v: lib.isAttrs v && ! lib.isDerivation v;
        globalSection = lib.filterAttrs (_: v: ! isSection v) cfg;
        sections = lib.filterAttrs (_: v: isSection v) cfg;
      in
        lib.generators.toINIWithGlobalSection {} {
          inherit globalSection sections;
        };
    in
      toIni
      (lib.attrsets.recursiveUpdate defaults cfg.settings);

    # systemd.tmpfiles.settings = {
    #   "jfa-go-dir-create" = {
    #     "/raid/media".d = {
    #       group = "media";
    #       mode = "751";
    #     };
    #   };
    # };

    systemd.services.jfa-go = {
      description = "jfa-go";
      wantedBy = ["multi-user.target"];
      after = ["jellyfin.service"];

      serviceConfig = let
        realCfgFile =
          if (cfg.cfgFile != null)
          then cfg.cfgFile
          else (pkgs.writeText "jfa-go.ini" cfg.cfgFileContent);

        apiCfgFile =
          pkgs.writeText
          "jfa-go_api-settings.json"
          (builtins.toJSON cfg.apiSettings);
      in {
        Type = "simple";

        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;

        EnvironmentFile =
          lib.optional
          (cfg.environmentFile != null)
          cfg.environmentFile;
        ExecStart = pkgs.writers.writeBash "jfa-go-init" ''
          rm -f "${cfg.dataDir}/cfg.ini"
          cp "${realCfgFile}" "${cfg.dataDir}/cfg.ini"
          chmod 600 "${cfg.dataDir}/cfg.ini"

          ${lib.getExe package} -c "${cfg.dataDir}/cfg.ini" -data ${cfg.dataDir}
        '';
        ExecStartPost = "${pkgs.writers.writePython3 "jfa-go_cfg.py" {
            libraries = with pkgs.python3Packages; [
              configparser
              requests
            ];
            doCheck = false;
          }
          # py
          ''
            import sys
            import time
            import json
            import configparser
            import requests

            _, CFG_FILE, API_CFG_FILE = sys.argv

            print("Start jfa-cfg")

            config = configparser.ConfigParser()
            # dumb botch to fix the global header
            with open(CFG_FILE, "r") as f:
                config_string = "[global]\n" + f.read()

            config.read_string(config_string)

            username = config["jellyfin"]["username"]
            password = config["jellyfin"]["password"]
            url = config["ui"]["jfa_url"].strip("/")

            while 1:
                res = requests.get(
                    url + "/token/login",
                    auth=(username, password),
                )

                if res.status_code < 500:
                    break

                print("Wating for jfa-go")
                time.sleep(1)

            auth_token = res.json()["token"]

            headers = {
                "accept": "application/json",
                "Authorization": f"Bearer {auth_token}",
            }

            with open(API_CFG_FILE, "r") as f:
                cfg = json.load(f)

            for path, val in cfg.items():
                print(
                    requests.post(
                        url + "/config/" + path.strip("/"),
                        headers=headers,
                        json=val,
                    ).text
                )
          ''} ${realCfgFile} ${apiCfgFile}";

        Restart = "on-failure";
      };
    };

    users.users = lib.mkIf (cfg.user == "jfa-go") {
      jfa-go = {
        group = cfg.group;
        # uid = 389;
        # home = cfg.home;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "jfa-go") {
      jfa-go = {}; # .gid = 389;
    };
  };
}
