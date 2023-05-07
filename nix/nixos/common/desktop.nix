{ config, pkgs, lib, inputs, ... }: {
  options.sysconfig.desktop = lib.mkEnableOption "desktop system configuration";

  config = lib.mkIf config.sysconfig.desktop {
    # Allow steam package for steam-hardware udev rules
    nixpkgs.config.allowUnfreePredicate = pkg:
      (lib.getName pkg) == "steam-original";

    nix.settings.keep-outputs = true;

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
      wgautomesh = {
        enable = true;
        gossipSecretFile = "/persist/vault/wgautomeshkey";
        enablePersistence = false;
        settings = {
          interface = "wg0";
          gossip_port = 47588;
          peers = [
            {
              pubkey = "c4Z0DD+bt2w/rbEfxLoR1PfnnwAMca3uZhWAFA5aLCc=";
              address = "10.66.0.2";
            }
          ];
        };
      };
    };

    networking = {
      wireguard.interfaces.wg0 = {
        listenPort = 54391;
        privateKeyFile = "/persist/vault/wgkey";
        generatePrivateKeyFile = true;
      };
      firewall.allowedUDPPorts = [ 54391 ];
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
