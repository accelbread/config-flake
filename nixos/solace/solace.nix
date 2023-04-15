{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    ./home-assistant.nix
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
    clight = {
      enable = true;
      settings = {
        backlight = {
          trans_step = 0.01;
          trans_timeout = 3;
          ac_timeouts = [ 10 10 10 ];
        };
        keyboard.disabled = true;
        gamma.disabled = true;
        dimmer.disabled = true;
        dpms.disabled = true;
        screen.disabled = true;
      };
    };
  };

  home-manager.sharedModules = [ ./home.nix ];

  hardware.cpu.amd.updateMicrocode = true;

  environment.systemPackages = with pkgs; [ nixgl.nixGLMesa ];
}

