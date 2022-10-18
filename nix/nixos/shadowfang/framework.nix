{ pkgs, flakes, ... }: {
  imports = [ flakes.nixos-hardware.nixosModules.framework ];

  boot = {
    kernelModules = [ "kvm-intel" "cpuid" "coretemp" ];
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    opengl.extraPackages = with pkgs; [ intel-compute-runtime ];
  };

  powerManagement.powertop.enable = true;

  services = {
    tlp = {
      enable = true;
      settings = { PCIE_ASPM_ON_BAT = "powersupersave"; };
    };
    power-profiles-daemon.enable = false;
    thermald.enable = true;
    xserver.videoDrivers = [ "modesetting" ];
    fprintd.enable = false;
    printing = {
      enable = true;
      webInterface = false;
    };
  };
}

