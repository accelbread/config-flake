inputs: mkSystem:
mkSystem {
  system = "aarch64-linux";
  modules = [
    ./rpi4.nix
    ./home-assistant.nix
    {
      sysconfig = {
        disks = {
          devices = [ "/dev/mmcblk1" ];
          size = "200GiB";
          swap = "16g";
        };
      };
      networking.hostId = "3c679a5b";
      system.stateVersion = "23.11";
    }
  ];
}
