# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  pkgs,
  ...
}:
let
  configFile = (pkgs.formats.json { }).generate "tailscaled.json" {
    version = "alpha0";
    locked = false;
    acceptDNS = false;
    acceptRoutes = false;
    runSSHServer = false;
  };
in
{
  boot.kernelModules = [ "tun" ];

  services.tailscale.disableUpstreamLogging = true;

  systemd.services.tailscaled = {
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
          + " --config=${configFile}"
        )
      ];
      User = "tailscaled";
      Group = "tailscaled";
      DynamicUser = true;
      AmbientCapabilities = [
        "CAP_NET_RAW"
        "CAP_NET_ADMIN"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_RAW"
        "CAP_NET_ADMIN"
      ];
      BindPaths = [ "/dev/net/tun" ];
      BindReadOnlyPaths = [
        "-/etc/localtime"
        "/etc/resolv.conf"
        "/etc/ssl/certs/ca-certificates.crt"
      ];
      DeviceAllow = "/dev/net/tun rw";
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
}
