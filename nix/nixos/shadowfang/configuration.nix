{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
    inputs.self.nixosModules.common
    inputs.self.nixosModules.desktop
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" ];
    kernelModules = [ "cpuid" "coretemp" ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    graphics.extraPackages = with pkgs; [ intel-compute-runtime ];
  };

  powerManagement.powertop.enable = true;

  home-manager.sharedModules = [ ./home.nix ];

  services = {
    logind.extraConfig = "IdleAction=hibernate";
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    tlp = {
      enable = true;
      settings = { PCIE_ASPM_ON_BAT = "powersupersave"; };
    };
    power-profiles-daemon.enable = false;
    thermald.enable = true;
    xserver.videoDrivers = [ "modesetting" ];
    fprintd.enable = false;
  };
}

