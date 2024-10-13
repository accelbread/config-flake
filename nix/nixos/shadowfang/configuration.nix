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
    bluetooth.powerOnBoot = false;
  };

  powerManagement.powertop.enable = true;

  home-manager.sharedModules = [ ./home.nix ];

  services = {
    logind.extraConfig = "IdleAction=hibernate";
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    thermald.enable = true;
    xserver.videoDrivers = [ "modesetting" ];
    fprintd.enable = false;
  };
}

