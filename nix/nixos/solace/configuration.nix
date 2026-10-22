# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ inputs, lib, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.self.nixosModules.desktop
    ./ups.nix
  ];

  nixpkgs = {
    hostPlatform.system = "x86_64-linux";
    config.rocmSupport = true;
  };

  ab.hardware = {
    cpu.amd.enable = true;
    gpu.amd.enable = true;
    memory.ecc.enable = true;
    disk.sata.enable = true;
    wireless.intel.ax200-ax210.enable = true;
    audio.realtek.alc882.enable = true;
  };

  networking.networkmanager.ethernet.macAddress = lib.mkForce "5E:34:87:DE:A3:7A";

  boot = {
    lanzaboote.autoEnrollKeys.includeChecksumsFromTPM = true;
    initrd.availableKernelModules = [
      "nvme"
    ];
    kernelModules = [
      "k10temp"
      "it87"
    ];
    kernelParams = [
      "efi=no_disable_early_pci_dma"
      "amdgpu.seamless=1"
      "amdgpu.ras_enable=1"
      "amdgpu.deep_color=1"
      "amdgpu.gpu_recovery=1"
    ];
    kernelPatches =
      with lib.kernel;
      lib.singleton {
        name = "hardware";
        patch = null;
        structuredExtraConfig = {
          GIGABYTE_WMI = module;
          I2C_PIIX4 = module;
          IGB = module;
          IGB_HWMON = no;
          PINCTRL_AMD = yes;
          R8169 = module;
          SCHED_CLUSTER = no;
          SENSORS_IT87 = module;
          SP5100_TCO = module;
          TCG_TIS = yes;
          X86_AMD_PLATFORM_DEVICE = yes;
        };
      };
    plymouth.theme = "details";
  };

  systemd.sleep.settings.Sleep.AllowSuspend = false;

  environment.etc."xdg/monitors.xml".source = ./monitors.xml;

  users = {
    users.remotebuild = {
      isSystemUser = true;
      group = "remotebuild";
      useDefaultShell = true;
    };
    groups.remotebuild = { };
  };

  nix.settings.trusted-users = [ "remotebuild" ];

  services = {
    openssh.settings.AllowGroups = [ "remotebuild" ];
    logind.settings.Login.IdleAction = "lock";
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    clight.enable = true;
    ratbagd.enable = true;
  };

  hardware.graphics.enable32Bit = false;

  ab.dconf.all = {
    "org/gnome/desktop/peripherals/touchpad" = {
      speed = 0.6;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };
  };

  hjem.users.archit.files.".config/wireplumber/wireplumber.conf.d/local.conf".source =
    ./wireplumber.conf;
}
