{ inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.desktop
    ./ups.nix
  ];

  nixpkgs = {
    config.rocmSupport = true;
    overlays = [
      (final: prev: {
        llama-cpp = prev.llama-cpp.override {
          openclSupport = true;
          rocmSupport = false;
          blasSupport = false;
        };
      })
    ];
  };

  environment.variables.HSA_OVERRIDE_GFX_VERSION = "10.3.0";

  boot = {
    initrd.availableKernelModules = [ "nvme" ];
    kernelModules = [ "cpuid" "k10temp" "it87" ];
    kernelParams = [ "amdgpu.deep_color=1" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  systemd.sleep.extraConfig = "AllowSuspend=no";

  services = {
    logind.extraConfig = "IdleAction=lock";
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    clight.enable = true;
    ratbagd.enable = true;
  };

  home-manager.sharedModules = [ ./home.nix ];

  hardware.cpu.amd.updateMicrocode = true;
}
