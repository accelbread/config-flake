# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ pkgs, lib, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
    inputs.self.nixosModules.common
    inputs.self.nixosModules.desktop
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
    kernelParams = [
      "rcu_nocbs=all"
      "workqueue.power_efficient=1"
      "pcie_aspm.policy=powersupersave"
    ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    intelgpu.vaapiDriver = "intel-media-driver";
    bluetooth = {
      powerOnBoot = false;
      settings.General = {
        PairableTimeout = 30;
        DiscoverableTimeout = 30;
      };
    };
    framework.enableKmod = false;
  };

  powerManagement.powertop.enable = true;

  environment.etc."xdg/monitors.xml".source = ./monitors.xml;

  home-manager.sharedModules = [ ./home.nix ];

  services = {
    logind.settings.Login.IdleAction = "hibernate";
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    thermald.enable = true;
    fprintd.enable = false;
    udev.packages = [
      (pkgs.writeTextFile {
        name = "xreal-udev-rules";
        destination = "/etc/udev/rules.d/70-xreal.rules";
        text = ''
          SUBSYSTEM=="usb", ATTR{idVendor}=="3318", MODE="0660", TAG+="uaccess"
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3318", MODE="0660", TAG+="uaccess"
        '';
      })
    ];
  };

  ab.dconf.all = with lib.gvariant; {
    "org/gnome/desktop/peripherals/touchpad" = {
      speed = 0.4;
      tap-to-click = true;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = mkInt32 900;
      sleep-inactive-ac-type = "hibernate";
      sleep-inactive-battery-timeout = mkInt32 900;
      sleep-inactive-battery-type = "hibernate";
    };
    "org/gnome/desktop/wm/preferences" = {
      audible-bell = false;
    };
  };
}

