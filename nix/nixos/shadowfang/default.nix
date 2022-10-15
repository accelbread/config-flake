flakes: mkSystem:
mkSystem {
  system = "x86_64-linux";
  modules = [
    ./framework.nix
    {
      disks = {
        boot = "/dev/nvme0n1p1";
        luks.disk1 = "/dev/nvme0n1p2";
      };
      networking.hostId = "fefcc72a";
      system.stateVersion = "22.05";
    }
  ];
}
