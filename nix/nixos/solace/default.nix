{
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    {
      sysconfig.disks = {
        devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
        size = "900GiB";
        swap = "64g";
      };
      networking.hostId = "41188d2a";
      system.stateVersion = "22.11";
    }
  ];
}
