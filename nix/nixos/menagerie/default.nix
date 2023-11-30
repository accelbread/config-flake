{
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
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
      nix.settings.trusted-public-keys = [
        "archit@solace-1:FOPmsx3GMBR/xMob8BamA0lMYlvoztnWFynllYb2sNE="
      ];
    }
  ];
}
