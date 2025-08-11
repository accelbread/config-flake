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

  systemd.services = {
    syncthing.serviceConfig = {
      ExecStartPre = "+" + pkgs.writers.writeBash "syncthing-make-data-dir" ''
        install -dm700 -o ${cfg.user} -g ${cfg.group} ${cfg.databaseDir}
      '';
      UMask = config.security.loginDefs.settings.UMASK;

      CapabilityBoundingSet = lib.mkForce "";
      IPAddressAllow = "localhost 100.64.0.0/10";
      IPAddressDeny = "any";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateIPC = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      ReadWritePaths = [ cfg.dataDir cfg.databaseDir ];
      RemoveIPC = true;
      RestrictAddressFamilies = [ "AF_INET" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" "~@privileged" ];
    };
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
      options = [
        "bind"
        "X-mount.idmap=${idmap}"
        "noatime"
        "nosuid"
        "nodev"
        "noexec"
      ];
    in
    foldl mergeAttrs { } (map
      (dir: {
        "${cfg.dataDir}/${dir}" = {
          device = "/persist/data/home/archit/${dir}";
          inherit options;
        };
      })
      dirs);

  preservation.preserveAt.state.users.syncthing = {
    home = cfg.dataDir;
    files = map (f: { file = f; mode = "0600"; }) [
      ".config/syncthing/key.pem"
      ".config/syncthing/cert.pem"
    ];
  };

  systemd.tmpfiles.settings.preservation = lib.flip lib.genAttrs
    (_: { d = { user = "syncthing"; group = "syncthing"; mode = "0700"; }; }) [
    "${cfg.dataDir}/.config"
    "${cfg.dataDir}/.config/syncthing"
  ];
}
