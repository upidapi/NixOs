{
  self,
  # https://discord.com/channels/568306982717751326/1271575537218748437/1271575951913783389
  # has to be explicit since the module system is lazy
  withSystem,
  ...
} @ args: let
  mkHosts = (import "${self}/parts/lib/mk_hosts.nix") ./. args;

  inherit (mkHosts) foldMapSystems mkSystem;

  nixosImgConfigs = foldMapSystems mkSystem [
    {
      system = "x86_64-linux";
      name = "full-installer";
      # cant have disko on a usb :)
      # TODO: ^^^ is that true? ^^^
      disko = false;
    }
    {
      system = "x86_64-linux";
      name = "minimal-installer";
      home-manager = false;
      disko = false;
    }
    {
      system = "x86_64-linux";
      name = "test-installer";
      home-manager = false;
      disko = false;
    }
  ];
in {
  # (commented things) taken from https://github.com/NotAShelf/nyx/blob/main/parts/iso-images.nix
  # ISO images based on available hosts. We avoid basing ISO images
  # on active (i.e. desktop) hosts as they likely have secrets set up.
  # Images below are designed specifically to be used as live media
  # and can be built with `nix build .#images.<hostname>`
  # alternatively hosts can be built with `nix build .#nixosConfigurations.hostName.config.system.build.isoImage`
  /*
  flake.images = let
    # gaea = self.nixosConfigurations."gaea";
    # erebus = self.nixosConfigurations."erebus";
    # atlas = self.nixosConfigurations."atlas".extendModules {modules = [installerModule];};
    full-installer-x86_64 = self.nixosConfigurations."full-installer-x86_64";
    minimal-installer-x86_64 = self.nixosConfigurations."minimal-installer-x86_64";
  in {
    # Installation iso(s)
    # gaea = gaea.config.system.build.isoImage;
    full-installer-x86_64 = full-installer-x86_64.config.system.build.isoImage;
    minimal-installer-x86_64 = minimal-installer-x86_64.config.system.build.isoImage;

    # air-gapped VM
    # erebus = erebus.config.system.build.isoImage;

    # Raspberry Pi 400
    # atlas = atlas.config.system.build.sdImage;
  };
  */

  flake.images =
    builtins.mapAttrs
    (_: imgConfig: imgConfig.config.system.build.isoImage)
    nixosImgConfigs;
}
