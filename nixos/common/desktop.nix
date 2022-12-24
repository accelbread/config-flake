{ config, pkgs, lib, flakes, ... }:
let
  inherit (flakes) self;
in
{
  options.sysconfig.desktop = lib.mkEnableOption "desktop system configuration";

  config = lib.mkIf config.sysconfig.desktop {
    # Allow steam package for steam-hardware udev rules
    nixpkgs.config.allowUnfreePredicate = pkg:
      (lib.getName pkg) == "steam-original";

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
      };
      xserver = {
        enable = true;
        excludePackages = [ pkgs.xterm ];
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
      };
      flatpak.enable = true;
    };

    programs = {
      bash.enableLsColors = false;
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.archit = self + /home/nixos.nix;
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
          ".ssh"
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
