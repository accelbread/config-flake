{
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    {
      sysconfig.disks = {
        devices = [ "/dev/nvme0n1" ];
        size = "3500GiB";
        swap = "64g";
      };
      networking.hostId = "fefcc72a";
      system.stateVersion = "23.11";
    }
  ];
}
