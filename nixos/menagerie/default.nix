flakes: mkSystem:
mkSystem {
  system = "aarch64-linux";
  modules = [
    ./home-assistant.nix
    {
      sysconfig.disks = {
        boot = "/dev/mmcblk0p1";
        luks.disk1 = "/dev/mmcblk0p2";
      };
      networking.hostId = "a588d445";
      system.stateVersion = "22.11";
    }
  ];
}
