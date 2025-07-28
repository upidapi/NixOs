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

  ports = {
    jellyseerr = 8097;
    jellyfin = 8096;

    radarr = 7878;
    sonarr = 8989;
    jackett = 9117;
    prowlarr = 9696;
    bazarr = 6767;

    qbit = 8080;
    flaresolverr = 8191;

    homepage = 8082;
  };

  ips = {
    mullvad = "192.168.15.1";
  };
}
