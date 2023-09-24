{ config, ... }: {
  services.home-assistant = {
    enable = true;
    configDir = "/persist/hass";
    openFirewall = false;
    configWritable = true;
    config = {
      homeassistant = {
        name = "Archit Home";
        country = "US";
        internal_url =
          let
            host = config.networking.hostName;
            port = config.services.home-assistant.config.http.server_port;
          in
          "http://${host}.fluffy-bebop.ts.net:${toString port}";
      };
      http.server_host = [ "0.0.0.0" ];
      frontend = { };
      mobile_app = { };
      config = { };
      zeroconf = { };
      sun = { };
      light = [{
        platform = "group";
        name = "Ceiling Light";
        unique_id = "ceiling_light";
        entities = [ "light.ceiling1" "light.ceiling2" ];
      }];
      scene = [
        {
          id = "scene_daytime";
          name = "Daytime";
          entities = {
            "light.ceiling_light" = {
              state = "on";
              brightness = 255;
              color_temp = 150;
            };
          };
        }
        {
          id = "scene_nighttime";
          name = "Nighttime";
          entities = {
            "light.ceiling_light" = {
              state = "on";
              brightness = 222;
              color_temp = 269;
            };
          };
        }
      ];
      automation = [{
        id = "automation_daynight";
        alias = "Day/Night";
        trigger = [
          {
            platform = "device";
            device_id = "66b7a727538a8d36f256074efedbda26";
            entity_id = "light.ceiling1";
            type = "turned_on";
            domain = "light";
          }
          {
            platform = "device";
            device_id = "4e02b550bdff5facc7d7a878296b34ca";
            entity_id = "light.ceiling2";
            type = "turned_on";
            domain = "light";
          }
          {
            platform = "time";
            at = "08:00:00";
          }
          {
            platform = "time";
            at = "20:00:00";
          }
        ];
        action = [{
          "if" = [{
            condition = "time";
            after = "08:00:00";
            before = "20:00:00";
            weekday = [ "sun" "mon" "tue" "wed" "thu" "fri" "sat" ];
          }];
          "then" = [{
            service = "scene.turn_on";
            target.entity_id = "scene.daytime";
          }];
          "else" = [{
            service = "scene.turn_on";
            target.entity_id = "scene.nighttime";
          }];
        }];
      }];
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    config.services.home-assistant.config.http.server_port
  ];
}
