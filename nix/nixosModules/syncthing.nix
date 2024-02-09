{ config, pkgs, lib, ... }:
let
  inherit (builtins) attrNames concatStringsSep;
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
    databaseDir = "/persist/cache/syncthing";
    settings = {
      options = {
        urAccepted = -1;
        relaysEnabled = false;
        localAnnounceEnabled = false;
        globalAnnounceEnabled = false;
        crashReportingEnabled = false;
        natEnabled = false;
        connectionPriorityQuicWan = 25;
      };
      folders = genAttrs dirs (k: {
        path = "~/${k}";
        devices = attrNames deviceIds;
      });
      devices = mapAttrs
        (k: v: { id = v; addresses = [ "quic://${k}.fluffy-bebop.ts.net" ]; })
        deviceIds;
    };
  };

  systemd.services.syncthing.serviceConfig = {
    ExecStartPre = "+" + pkgs.writers.writeBash "syncthing-make-data-dir" ''
      install -dm700 -o ${cfg.user} -g ${cfg.group} ${cfg.databaseDir}
    '';
    RestrictNetworkInterfaces = "lo tailscale0";
    UMask = config.security.loginDefs.settings.UMASK;
  };

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 22000 ];
  };

  fileSystems =
    let
      inherit (config.users) users groups;
      idmap = concatStringsSep " " [
        "u:${toString users.archit.uid}:${toString users.syncthing.uid}:1"
        "g:${toString groups.users.gid}:${toString groups.syncthing.gid}:1"
        "b:0:0:1"
      ];
    in
    foldl mergeAttrs { } (map
      (dir: {
        "${cfg.dataDir}/${dir}" = {
          device = "/persist/data/home/archit/${dir}";
          options = [
            "bind"
            "X-mount.idmap=${idmap}"
            "noatime"
            "nosuid"
            "nodev"
            "noexec"
          ];
        };
      })
      dirs);

  environment.persistence."/persist/state".users.syncthing = {
    home = cfg.dataDir;
    files = [
      ".config/syncthing/key.pem"
      ".config/syncthing/cert.pem"
    ];
  };
}
