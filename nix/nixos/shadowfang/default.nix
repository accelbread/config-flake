inputs: mkSystem:
mkSystem {
  system = "x86_64-linux";
  modules = [
    ./framework.nix
    {
      sysconfig = {
        desktop = true;
        disks = {
          devices = [ "/dev/nvme0n1" ];
          size = "900GiB";
          swap = "32g";
        };
      };
      networking.hostId = "fefcc72a";
      system.stateVersion = "22.05";
    }
  ];
}
