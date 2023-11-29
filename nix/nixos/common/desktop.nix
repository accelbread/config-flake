{ config, pkgs, lib, inputs, ... }: {
  options.sysconfig.desktop = lib.mkEnableOption "desktop system configuration";

  config = lib.mkIf config.sysconfig.desktop {
    # Allow steam package for steam-hardware udev rules
    nixpkgs.config.allowUnfreePredicate = pkg:
      (lib.getName pkg) == "steam-original";

    nix.settings = {
      keep-outputs = true;
      extra-sandbox-paths = lib.optional config.programs.ccache.enable
        config.programs.ccache.cacheDir;
    };

    users.users.archit.extraGroups = [ "dialout" "wireshark" ];

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
      clight.settings = {
        backlight = {
          no_smooth_transition = true;
          ac_timeouts = [ 10 10 10 ];
        };
        keyboard.disabled = true;
        gamma.disabled = true;
        dimmer.disabled = true;
        dpms.disabled = true;
        screen.disabled = true;
      };
      flatpak.enable = true;
      # uaccess rules must come before 73-seat-late.rules
      udev.packages = lib.singleton (pkgs.writeTextFile {
        name = "usb-disk-udev-rules";
        destination = "/etc/udev/rules.d/70-usb-disks.rules";
        text = ''
          SUBSYSTEMS=="usb", SUBSYSTEM=="block", TAG+="uaccess"
        '';
      });
    };

    networking.firewall.interfaces."tailscale0" = rec {
      allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };

    programs = {
      ccache.enable = true;
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
      users.archit = ./home;
      extraSpecialArgs = { inherit inputs; };
    };

    environment = {
      persistence."/persist".users = {
        archit = {
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
            ".librewolf/profile"
            ".local/share/vault"
            ".local/share/tpm2_pkcs11"
            ".local/share/gnupg"
            ".local/share/pass"
            ".local/share/flatpak"
            ".var/app/com.valvesoftware.Steam"
          ];
          files = [
            ".face"
            ".config/monitors.xml"
            ".ssh/ssh-cert.pub"
          ];
        };
        root = {
          home = "/root";
          directories = [ ".tpm2_pkcs11" ];
        };
      };
      wordlist = {
        enable = true;
        lists.WORDLIST = [
          "${pkgs.scowl}/share/dict/words.txt"
          "${pkgs.miscfiles}/share/web2"
        ];
      };
      etc."nixos/flake.nix".source = pkgs.runCommandLocal "flake-symlink" { } ''
        ln -s "/home/archit/projects/config-flake/flake.nix" $out
      '';
    };
  };
}
