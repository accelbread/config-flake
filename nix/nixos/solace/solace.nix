{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    ./ups.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" ];
    kernelModules = [ "cpuid" "k10temp" "it87" ];
    kernelParams = [ "amdgpu.deep_color=1" ];
  };

  systemd.sleep.extraConfig = "AllowSuspend=no";

  services = {
    logind.extraConfig = "IdleAction=lock";
    usbguard.rules = builtins.readFile ./usbguard-rules.conf;
    clight.enable = true;
  };

  home-manager.sharedModules = [ ./home.nix ];

  hardware.cpu.amd.updateMicrocode = true;

  environment.systemPackages = with pkgs; [ nixgl.nixGLMesa ];

  nix = {
    sshServe = {
      enable = true;
      write = true;
      protocol = "ssh-ng";
    };
    settings = {
      allowed-users = [ "nix-ssh" ];
      # Not needed with nix 2.16?
      trusted-users = [ "nix-ssh" ];
    };
  };
}
