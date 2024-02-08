{ config, pkgs, lib, ... }:
let
  inherit (builtins) attrNames;
  inherit (lib) foldl genAttrs mapAttrs mergeAttrs;

  cfg = config.services.syncthing;
  dirs = [ "Documents" "Music" "Pictures" "Videos" "Library" ];
  deviceIds = {
    solace = "GFGS44Z-7J5HL34-WHN7T66-W5FDFQR-6QCTTFP-4DKACXB-ANSRE2I-BTC6RAW";
    shadowfang = "SQVQEQJ-WYREPRO-Q5IOX3S-V2BG2LE-J5XSEKB-G6GYXDH-RPYGWV2-FETQEAF";
  };
in
{
  services.syncthing = {
    enable = true;
    databaseDir = "/persist/state/syncthing";
    settings = {
      options = {
        urAccepted = -1;
        relaysEnabled = false;
        localAnnounceEnabled = false;
        globalAnnounceEnabled = false;
        natEnabled = false;
      };
      folders = genAttrs dirs (k: {
        path = "~/${k}";
        devices = attrNames deviceIds;
      });
      devices = mapAttrs
        (k: v: { id = v; addresses = [ "tcp://${k}.fluffy-bebop.ts.net" ]; })
        deviceIds;
    };
  };

  systemd.services.syncthing.serviceConfig = {
    ExecStartPre = "+" + pkgs.writers.writeBash "syncthing-make-data-dir" ''
      install -dm700 -o ${cfg.user} -g ${cfg.group} ${cfg.databaseDir}
    '';
    RestrictNetworkInterfaces = "lo tailscale0";
  };

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 22000 ];
  };

  fileSystems = foldl mergeAttrs { } (map
    (dir: {
      "${cfg.dataDir}/${dir}" = {
        device = "/home/archit/${dir}";
        fsType = "fuse.bindfs";
        options = [
          "noatime"
          "nosuid"
          "nodev"
          "noexec"
          "default_permissions"
          "map=archit/syncthing:@users/@syncthing"
        ];
      };
    })
    dirs);

  environment = {
    systemPackages = [ pkgs.bindfs ];
    persistence."/persist/state".users.syncthing = {
      home = cfg.dataDir;
      files = [
        ".config/syncthing/key.pem"
        ".config/syncthing/cert.pem"
      ];
    };
  };

}
