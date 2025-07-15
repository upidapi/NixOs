{
  inputs,
  self,
  ...
}: let
  dLib = inputs.deploy-rs.lib.x86_64-linux;
in {
  flake.deploy = {
    nodes = {
      upinix-pc = {
        hostname = "ssh.upidapi.dev";
        profiles.system = {
          sshUser = "upidapi";
          user = "root";

          sudo = "sudo -S -u";
          interactiveSudo = true;

          path = dLib.activate.nixos self.nixosConfigurations.upinix-pc;
        };
        magicRollback = true;
        remoteBuild = true;
      };
    };

    # user = "root";

    autoRollback = true;
    magicRollback = true;
    remoteBuild = true;

    activationTimeout = 240;
    confirmTimeout = 30;
  };
}
