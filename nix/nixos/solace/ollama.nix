{
  services.ollama = {
    enable = true;
    listenAddress = "0.0.0.0";
  };

  environment.persistence."/persist/cache".directories = [
    "/var/lib/private/ollama/models"
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 11434 ];
}
