{ config, pkgs, flakes, hostname, ... }: {
  imports = [ flakes.nixos-hardware.nixosModules.raspberry-pi-4 ];

  boot.loader.generic-extlinux-compatible.enable = false;

  # DNSCrypt-proxy needs NTP which needs DNS; use public resolver for boot
  networking.nameservers = [ "1.1.1.1" ];

  systemd.services.enable-local-resolver =
    assert config.networking.resolvconf.enable; {
      description = "Set DNS resolver to localhost";
      after = [ "time-sync.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${pkgs.openresolv}/sbin/resolvconf -m 1 -a static <<EOF
        nameserver 127.0.0.1
        EOF
      '';
    };

  networking.enableIPv6 = false;

  services.home-assistant = {
    enable = true;
    configDir = "/persist/config/hass";
    openFirewall = true;
    configWritable = true;
    config = {
      http.server_host = [ "0.0.0.0" ];
      homeassistant = {
        name = "Archit Home";
        internal_url = "http://${hostname}.local:8123";
      };
      automation = "!include automations.yaml";
      scene = "!include scenes.yaml";
      script = "!include scripts.yaml";
      dhcp = { };
      zeroconf = { };
      sun = { };
      schedule = { };
      config = { };
      frontend = { };
      history = { };
      image = { };
      logbook = { };
      mobile_app = { };
    };
  };
}
