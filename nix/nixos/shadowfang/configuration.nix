{ lib, pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
    inputs.self.nixosModules.common
    inputs.self.nixosModules.desktop
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" ];
    kernelModules = [ "cpuid" "coretemp" ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    graphics.extraPackages = with pkgs; [ intel-compute-runtime ];
    bluetooth = {
      powerOnBoot = false;
      settings = {
        General = {
          PairableTimeout = 30;
          DiscoverableTimeout = 30;
        };
        Policy.Privacy = "network/on";
      };
    };
    framework.enableKmod = false;
  };

  powerManagement.powertop.enable = true;

  sysconfig.monitors = ./monitors.xml;

  home-manager.sharedModules = [ ./home.nix ];

  services = {
    logind.settings.Login.IdleAction = "hibernate";
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    thermald.enable = true;
    xserver.videoDrivers = [ "modesetting" ];
    fprintd.enable = false;
  };

  sysconfig.dconf = with lib.gvariant; {
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

