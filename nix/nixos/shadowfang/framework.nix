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

  systemd.services.reinit-touchpad = {
    enable = true;
    description = "Reload i2c_hid_acpi on wakeup.";
    after = [ "systemd-hibernate.service" ];
    wantedBy = [ "systemd-hibernate.target" ];
    script = ''
      rmmod i2c_hid_acpi
      modprobe i2c_hid_acpi
    '';
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

