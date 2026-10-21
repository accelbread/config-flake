# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.desktop
  ];

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "solace";
        sshUser = "remotebuild";
        sshKey = "/persist/state/system/keys/remote_build_ssh_key";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        protocol = "ssh-ng";
        maxJobs = 32;
        speedFactor = 4;
        supportedFeatures = [
          "ca-derivations"
          "nixos-test"
          "big-parallel"
          "kvm"
        ];
      }
    ];
  };

  boot.kernelParams = [
    "rcu_nocbs=all"
    "workqueue.power_efficient=1"
    "pcie_aspm.policy=powersupersave"
  ];

  hardware.bluetooth = {
    powerOnBoot = false;
    settings.General = {
      PairableTimeout = 30;
      DiscoverableTimeout = 30;
    };
  };

  powerManagement.powertop.enable = true;

  services = {
    logind.settings.Login.IdleAction = "hibernate";
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
