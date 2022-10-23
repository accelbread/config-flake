flakes: mkSystem:
mkSystem {
  system = "x86_64-linux";
  modules = [
    ./solace.nix
    {
      disks = {
        boot = "/dev/nvme0n1p1";
        luks = {
          disk1 = "/dev/nvme0n1p2";
          disk2 = "/dev/nvme1n1p2";
        };
      };
      networking.hostId = "41188d2a";
      system.stateVersion = "22.05";
    }
  ];
}
