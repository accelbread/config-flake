# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  lib,
  pkgs,
  ...
}:
let
  json = pkgs.formats.json { };
  configFile = json.generate "tailscaled.json" (
    {
      version = "alpha0";
      locked = false;
      acceptDNS = false;
      acceptRoutes = false;
      exitNode = "";
      runSSHServer = false;
    }
    // config.ab.tailscale.extraConfig
  );
in
{
  options.ab.tailscale.extraConfig = lib.mkOption {
    type = lib.types.attrsOf json.type;
    default = { };
  };

  config = {
    boot.kernelModules = [ "tun" ];

    services.tailscale.disableUpstreamLogging = true;

    systemd.services.tailscaled = {
      after = [
        "tpm2.target"
        "tpm2-udev-trigger.service"
      ];
      confinement.enable = true;
      path = lib.mkForce [ ];
      environment.TS_DEBUG_FIREWALL_MODE = "nftables";
      serviceConfig = {
        ExecStart = [
          ""
          (
            "${pkgs.tailscale}/bin/tailscaled"
            + " --statedir /var/lib/tailscale"
            + " --socket=/run/tailscale/tailscaled.sock"
            + " --encrypt-state"
            + " --config=${configFile}"
          )
        ];
        User = "tailscaled";
        Group = "tailscaled";
        SupplementaryGroups = [ config.security.tpm2.tssGroup ];
        DynamicUser = true;
        AmbientCapabilities = [
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
        ];
        CapabilityBoundingSet = [
          "CAP_NET_RAW"
          "CAP_NET_ADMIN"
        ];
        BindPaths = [
          "/dev/net/tun"
          "/dev/tpmrm0"
        ];
        BindReadOnlyPaths = [
          "-/etc/localtime"
          "/etc/resolv.conf"
          "/etc/ssl/certs/ca-certificates.crt"
        ];
        DeviceAllow = [
          "/dev/net/tun rw"
          "/dev/tpmrm0 rw"
        ];
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateIPC = true;
        PrivateMounts = true;
        PrivateTmp = true;
        # CAP_NET_ADMIN must apply to the host network namespace.
        PrivateUsers = false;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RemoveIPC = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@known"
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@keyring"
          "~@mount"
          "~@obsolete"
          "~@pkey"
          "~@raw-io"
          "~@reboot"
          "~@swap"
          "~@module"
        ];
        UMask = 077;
      };
    };
  };
}
