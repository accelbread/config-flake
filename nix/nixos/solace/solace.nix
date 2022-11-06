{ pkgs, flakes, ... }: {
  imports = [
    flakes.nixos-hardware.nixosModules.common-cpu-amd
    flakes.nixos-hardware.nixosModules.common-gpu-amd
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" ];
    kernelModules = [ "cpuid" "k10temp" "it87" ];
    kernelParams = [ "amdgpu.deep_color=1" ];
  };

  nixpkgs.overlays = [
    flakes.self.overlays.amd-cpu
    (final: prev: {
      clightd = (prev.clightd.override {
        enableDpms = false;
        enableGamma = false;
        enableScreen = false;
      }).overrideAttrs (finalAttrs: prevAttrs: {
        cmakeFlags = prevAttrs.cmakeFlags ++ [ "-DENABLE_YOCTOLIGHT=1" ];
      });
    })
  ];

  systemd.sleep.extraConfig = "AllowSuspend=no";

  services = {
    logind.extraConfig = "IdleAction=lock";
    clight = {
      enable = true;
      settings = {
        backlight = {
          trans_step = 0.01;
          trans_timeout = 3;
          ac_timeouts = [ 10 60 10 ];
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

  environment = {
    persistence."/persist".users.archit.directories = [ ".mozilla" ];
    systemPackages = with pkgs; [ firefox ];
  };

  hardware.cpu.amd.updateMicrocode = true;
}

