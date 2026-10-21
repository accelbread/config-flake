# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
    inputs.self.nixosModules.laptop
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "atkbd"
      "i8042"
      "xhci_pci"
      "usbhid"
      "hid_generic"
      "thunderbolt"
    ];
    kernelModules = [ "coretemp" ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    intelgpu.vaapiDriver = "intel-media-driver";
    framework.enableKmod = false;
  };

  environment.etc."xdg/monitors.xml".source = ./monitors.xml;

  services = {
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    thermald.enable = true;
  };

  ab.dconf.all."org/gnome/desktop/peripherals/touchpad" = {
    speed = 0.4;
    tap-to-click = true;
  };
}
