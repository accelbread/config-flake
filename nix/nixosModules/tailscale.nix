{ pkgs, ... }: {
  boot.kernelModules = [ "tun" ];

  systemd.services.tailscaled = {
    environment.TS_DEBUG_FIREWALL_MODE = "nftables";
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.tailscale}/bin/tailscaled --statedir /var/lib/private/tailscale"
      ];
      User = "tailscaled";
      Group = "tailscaled";
      DynamicUser = true;
      AmbientCapabilities = [ "CAP_NET_RAW" "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_RAW" "CAP_NET_ADMIN" ];
      DeviceAllow = "/dev/net/tun rw";
      DevicePolicy = "closed";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateIPC = true;
      PrivateMounts = true;
      PrivateTmp = true;
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
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
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
