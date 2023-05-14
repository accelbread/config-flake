{ config, pkgs, lib, inputs, ... }: {
  options.sysconfig.desktop = lib.mkEnableOption "desktop system configuration";

  config = lib.mkIf config.sysconfig.desktop {
    # Allow steam package for steam-hardware udev rules
    nixpkgs.config.allowUnfreePredicate = pkg:
      (lib.getName pkg) == "steam-original";

    nix.settings.keep-outputs = true;

    users.users.archit.extraGroups = [ "dialout" "wireshark" "adbusers" ];

    hardware = {
      opengl.enable = true;
      sensor.iio.enable = true;
      steam-hardware.enable = true;
    };

    sound.enable = true;

    services = {
      pipewire = {
        enable = true;
        pulse.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
      };
      xserver = {
        enable = true;
        excludePackages = [ pkgs.xterm ];
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
      };
      flatpak.enable = true;
      tailscale.enable = true;
    };

    networking.firewall = {
      allowedUDPPorts = [ config.services.tailscale.port ];
      interfaces."tailscale0" = rec {
        allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };
    };

    programs = {
      bash.enableLsColors = false;
      wireshark = {
        enable = true;
        package = pkgs.wireshark;
      };
      adb.enable = true;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.archit = ../../homeModules/nixos.nix;
      extraSpecialArgs = { inherit inputs; };
    };

    environment = {
      persistence."/persist".users.archit = {
        directories = [
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Videos"
          "Library"
          "projects"
          "playground"
          ".ssh/config.d"
          ".config/emacs"
          ".config/gsconnect"
          ".librewolf/profile"
          ".local/share/tpm2_pkcs11"
          ".local/share/gnupg"
          ".local/share/pass"
          ".local/share/Zeal"
          ".local/share/flatpak"
          ".var/app"
        ];
        files = [ ".face" ".config/monitors.xml" ];
      };
      wordlist = {
        enable = true;
        lists.WORDLIST = [ "${pkgs.miscfiles}/share/web2" ];
      };
    };
  };
}
