{
  services.ollama = {
    enable = true;
    listenAddress = "0.0.0.0";
  };

  environment.persistence."/persist/cache".directories = [
    "/var/lib/private/ollama/models"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 11434 ];

  systemd.services.ollama.serviceConfig = {
    UMask = 077;
    CapabilityBoundingSet = "";
    DeviceAllow = [
      "/dev/dri/card0 rw"
      "/dev/dri/renderD128 rw"
      "/dev/kfd rw"
    ];
    DevicePolicy = "closed";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateIPC = true;
    PrivateMounts = true;
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
    RemoveIPC = true;
    RestrictAddressFamilies = [ "AF_INET" ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" "~@privileged" ];
  };
}
