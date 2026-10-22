# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
    inputs.self.nixosModules.framework
    inputs.self.nixosModules.laptop
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  ab.hardware = {
    cpu.intel.enable = true;
    gpu.xe = {
      enable = true;
      force = true;
    };
    input.mouse.ps2.enable = true;
    wireless.intel.ax200-ax210.enable = true;
    audio.intel.sof.enable = true;
  };

  boot.kernelPatches =
    with lib.kernel;
    lib.singleton {
      name = "hardware";
      patch = null;
      structuredExtraConfig = {
        PINCTRL_TIGERLAKE = module;
        SND_SOC_SOF_TIGERLAKE = module;
        SND_HDA_CODEC_SIGMATEL = module;
        TCG_TIS = yes;
      };
    };

  environment.etc."xdg/monitors.xml".source = ./monitors.xml;

  services.usbguard.rules = builtins.readFile ./usbguard-rules.conf;

  ab.dconf.all."org/gnome/desktop/peripherals/touchpad" = {
    speed = 0.4;
    tap-to-click = true;
  };
}
