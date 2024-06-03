{ pkgs, ... }:
let
  port = 25236;
  args = [
    "--model /persist/cache/models/dolphin-2.7-mixtral-8x7b-q5_k_m.gguf"
    "--alias mixtral-8x7b"
    "--ctx-size 32768"
    "--n-gpu-layers 100"
    "--host 0.0.0.0"
    "--port ${toString port}"
    "--system-prompt-file ${./system_prompt}"
    "--log-disable"
  ];
in
{
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ port ];

  systemd.services.llama-cpp-server = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "LLaMA.cpp HTTP Server";
    environment.ROCR_VISIBLE_DEVICES = "1,0";
    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.llama-cpp}/bin/server ${toString args}";
      DynamicUser = true;
      UMask = 077;
      CapabilityBoundingSet = "";
      DeviceAllow = [
        "/dev/dri/card0 rw"
        "/dev/dri/card1 rw"
        "/dev/dri/renderD128 rw"
        "/dev/dri/renderD129 rw"
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
      SystemCallErrorNumber = "EPERM";
    };
  };
}
