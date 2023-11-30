{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.self.nixosModules.desktop
    ./ups.nix
  ];

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

  environment.systemPackages = with pkgs; [ nixgl.nixGLMesa ];
}
