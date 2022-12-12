{ pkgs, flakes, hostname, ... }: {
  imports = [ flakes.nixos-hardware.nixosModules.raspberry-pi-4 ];

  boot.loader.generic-extlinux-compatible.enable = false;

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    configWritable = true;
    lovelaceConfigWritable = true;
    config = {
      http.server_host = [ "0.0.0.0" ];
      homeassistant = {
        name = "Archit Home";
        internal_url = "http://${hostname}.local:8123";
      };
      default_config = { };
    };
    lovelaceConfig = { };
  };
}
