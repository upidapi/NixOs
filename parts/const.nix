{lib, ...}: let
  inherit (builtins) elem;
  inherit (lib.attrsets) filterAttrs;
  filterAttrsList = inp: white_list: (filterAttrs (x: elem white_list x) inp);
in {
  keys = rec {
    # Users
    users = {
      upidapi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAZGOYHhwBexxezYimuNmPqU2nh5dyJrmJLRvE3Nm/B upidapi@upidapi-nix-pc";

      admin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0MLLzh+8UzScYKSVSN0j0su890AhlfWNz8Lz3lQ0tl admin";
    };

    # Hosts
    machines = {
      full-installer-x86_64 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDf1kXG1cPMYLKvV7EgOrfGax4IyR4aCQW7Y+7vA1AMp root@full-installer-x86_64";
      minimal-installer-x86_64 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvANBIwQX5DD5J5ymR5LJ9aqbDC0h17OmGjbvZqY2Iq root@minimal-installer-x86_64
";
      upinix-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXY5Aww+QDwPvc0MfC+QOINujmZRr6+npOxPm6v+2AC root@upinix-laptop";
      upinix-pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFz862CylfPGEHYk0cFZ/rsQvM+CvpMdjW+wFVGNFM5m root@upinix-pc";
    };

    # Shorthand aliases for various collections of host keys

    servers = filterAttrsList machines [];
    workstations = filterAttrsList machines [
      "upinix-pc"
      "upinix-laptop"
    ];
  };

  wg = {
    upinix-pc = "LVylhaaXYXzsm4nLkFocHASj49p+o/AsVL7hGx95jRE=";
    upinix-laptop = "WtAd0Hs7vRRuJ7mQdpiy4E7Wj4FMUbGuGAhX1jLGM3A=";
    upi-phone = "iHBW6dH7PYSFbV2QJTx7PoaaDB9YnzRgVjIeTqOU6Ww=";
    guest = "zWnBubemXYdP+H2MKZgqgKl7n3Izn8UI/LMRrS1bXx8=";
  };

  ports = {
    radarr = 8500;
    sonarr = 8501;
    lidarr = 8502;
    bazarr = 8503;

    jackett = 8504;
    prowlarr = 8505;
    flaresolverr = 8506;

    jellyseerr = 8507;
    jellyfin = 8508;

    qbit = 8509;

    homepage = 8600;
    transfer-sh = 8601;

    game-site = 8602;
    game-site-beta = 8603;

    syncthing = 8384;
    wireguard = 51820;
    wg-easy = 51821;

    mc-server = 25565;
    mc-server-b = 25566;
  };

  ips = {
    mullvad = "192.168.16.1";
    proton = "192.168.15.1";

    upinix-pc = "192.168.68.137";
    upinix-laptop = "192.168.68.132";
  };
}
