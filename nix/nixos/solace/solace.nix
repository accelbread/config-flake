{ pkgs, flakes, ... }: {
  imports = [
    flakes.nixos-hardware.nixosModules.common-cpu-amd
    flakes.nixos-hardware.nixosModules.common-gpu-amd
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" ];
    kernelModules = [ "cpuid" ];
    kernelParams = [ "amdgpu.deep_color=1" ];
  };

  nixpkgs.overlays = [ flakes.self.overlays.amd-cpu ];

  home-manager.sharedModules = [ ./home.nix ];

  environment = {
    persistence."/persist".users.archit.directories = [ ".mozilla" ];
    systemPackages = with pkgs; [ firefox ];
  };

  hardware.cpu.amd.updateMicrocode = true;
}

