flakes: mkSystem:
mkSystem {
  system = "x86_64-linux";
  modules = [
    ./solace.nix
    {
      sysconfig = {
        desktop = true;
        disks = {
          devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
          size = "900GiB";
          swap = "64g";
        };
      };
      networking.hostId = "41188d2a";
      system.stateVersion = "22.05";
    }
  ];
}
