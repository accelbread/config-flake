# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
    inputs.self.nixosModules.framework
    inputs.self.nixosModules.laptop
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  ab.hardware = {
    cpu.intel.enable = true;
    gpu.xe.enable = true;
    input.mouse.ps2.enable = true;
    wireless.intel.be211.enable = true;
    audio.realtek.alc269.enable = true; # ALC285
  };

  boot.kernelPatches =
    with lib.kernel;
    lib.singleton {
      name = "hardware";
      patch = null;
      structuredExtraConfig = {
        PINCTRL_INTEL_PLATFORM = module;
        TCG_CRB = yes;
      };
    };

  environment.etc."xdg/monitors.xml".source = ./monitors.xml;
}
