{ inputs, lib, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.desktop
    ./ups.nix
    ./ollama.nix
  ];

  nixpkgs = {
    config.rocmSupport = true;
    overlays = [
      (final: prev: {
        ollama = prev.ollama.override {
          acceleration = "rocm";
        };
      })
    ];
  };

  networking.networkmanager.ethernet.macAddress =
    lib.mkForce "5E:34:87:DE:A3:7A";

  boot = {
    initrd.availableKernelModules = [ "nvme" ];
    kernelModules = [ "cpuid" "k10temp" "it87" ];
    kernelParams = [ "amdgpu.deep_color=1" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  systemd = {
    sleep.extraConfig = "AllowSuspend=no";
    tmpfiles.rules = [
      "L+ /run/gdm/.config/monitors.xml - gdm gdm - ${./monitors.xml}"
    ];
  };

  services = {
    logind.extraConfig = "IdleAction=lock";
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    clight.enable = true;
    ratbagd.enable = true;
  };

  home-manager.sharedModules = [ ./home.nix ];

  hardware.cpu.amd.updateMicrocode = true;
}
