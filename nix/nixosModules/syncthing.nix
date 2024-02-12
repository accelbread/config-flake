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
  phoneDirs = [ "Documents" "Pictures" "Camera" ];
  phoneIds.google-pixel-6 = "QLTYZCU-R3ZMKFP-T7VEJSG-AMPP6AH-EIXIQQF-EZOJ3CQ-VFN4AM6-URJR2QD";
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
      folders = (genAttrs dirs (k: {
        path = "~/${k}";
        devices = attrNames deviceIds;
      })) // (foldl mergeAttrs { } (map
        (k: {
          "phone/${k}" = {
            path = "~/phone/${k}";
            devices = (attrNames deviceIds) ++ (attrNames phoneIds);
          };
        })
        phoneDirs));
      devices = mapAttrs
        (k: v: { id = v; addresses = [ "quic://${k}.fluffy-bebop.ts.net" ]; })
        (deviceIds // phoneIds);
    };
  };

  systemd.services = {
    syncthing.serviceConfig = {
      ExecStartPre = "+" + pkgs.writers.writeBash "syncthing-make-data-dir" ''
        install -dm700 -o ${cfg.user} -g ${cfg.group} ${cfg.databaseDir}
      '';
      IPAddressAllow = "localhost 100.64.0.0/10";
      IPAddressDeny = "any";
      UMask = config.security.loginDefs.settings.UMASK;
    };
  } // (foldl mergeAttrs { } (map
    (dir: {
      "chown-persist-data-phone-${dir}" = {
        description = "Chown /persist/data/phone/${dir}";
        wantedBy = [ "var-lib-syncthing-phone-${dir}.mount" ];
        after = [ "var-lib-syncthing-phone-${dir}.mount" ];
        before = [ "syncthing.service" ];
        script = ''
          chown archit:users /persist/data/phone
          chown archit:users /persist/data/phone/${dir}
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    })
    phoneDirs));

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
      options = [
        "bind"
        "X-mount.idmap=${idmap}"
        "noatime"
        "nosuid"
        "nodev"
        "noexec"
      ];
    in
    (foldl mergeAttrs { } (map
      (dir: {
        "${cfg.dataDir}/${dir}" = {
          device = "/persist/data/home/archit/${dir}";
          inherit options;
        };
      })
      dirs)) //
    (foldl mergeAttrs { } (map
      (dir: {
        "${cfg.dataDir}/phone/${dir}" = {
          device = "/persist/data/phone/${dir}";
          inherit options;
        };
      })
      phoneDirs));

  environment.persistence."/persist/state".users.syncthing = {
    home = cfg.dataDir;
    files = [
      ".config/syncthing/key.pem"
      ".config/syncthing/cert.pem"
    ];
  };
}
