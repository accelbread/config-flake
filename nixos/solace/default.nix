flakes: mkSystem:
mkSystem {
  system = "x86_64-linux";
  modules = [
    ./solace.nix
    {
      sysconfig = {
        desktop = true;
        disks = {
          boot = "/dev/nvme0n1p1";
          luks = {
            disk1 = "/dev/nvme0n1p2";
            disk2 = "/dev/nvme1n1p2";
          };
        };
      };
      swapDevices = [
        { device = "/dev/solace_vg1/swap"; }
        { device = "/dev/solace_vg2/swap"; }
      ];
      networking.hostId = "41188d2a";
      system.stateVersion = "22.05";
    }
  ];
}
