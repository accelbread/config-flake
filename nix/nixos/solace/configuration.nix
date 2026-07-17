{ inputs, lib, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.desktop
    ./ups.nix
  ];

  nixpkgs = {
    hostPlatform.system = "x86_64-linux";
    config.rocmSupport = true;
  };

  networking.networkmanager.ethernet.macAddress =
    lib.mkForce "5E:34:87:DE:A3:7A";

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usbhid"
      "hid_generic"
    ];
    kernelModules = [ "k10temp" "it87" ];
    kernelParams = [
      "efi=no_disable_early_pci_dma"
      "amdgpu.seamless=1"
      "amdgpu.ras_enable=1"
      "amdgpu.deep_color=1"
      "amdgpu.gpu_recovery=1"
    ];
    plymouth.theme = "details";
  };

  systemd.sleep.settings.Sleep.AllowSuspend = false;

  sysconfig.monitors = ./monitors.xml;

  services = {
    logind.settings.Login.IdleAction = "lock";
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    clight.enable = true;
    ratbagd.enable = true;
  };

  home-manager.sharedModules = [ ./home.nix ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    graphics.enable32Bit = false;
  };

  sysconfig.dconf = {
    "org/gnome/desktop/peripherals/touchpad" = { speed = 0.6; };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };
  };
}
