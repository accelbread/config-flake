{ pkgs, lib, ... }: {
  environment.persistence."/persist/cache".directories = [
    "/var/lib/private/ollama/models"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 11434 ];

  systemd.services.ollama = {
    wantedBy = [ "multi-user.target" ];
    description = "Server for local large language models";
    after = [ "network.target" ];
    environment = {
      HOME = "%S/ollama";
      OLLAMA_MODELS = "%S/ollama/models";
      OLLAMA_HOST = "0.0.0.0";
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    };
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.ollama} serve";
      WorkingDirectory = "/var/lib/ollama";
      DynamicUser = true;
      StateDirectory = [ "ollama" ];
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
  };
}
