{ pkgs, ... }: {
  services.mosquitto = {
    enable = true;
    persistence = false;
    logType = [ "error" "warning" "notice" "information" ];
    listeners = [{
      address = "0.0.0.0";
      settings.allow_anonymous = true;
      acl = [ "topic readwrite #" ];
    }];
  };
  networking.firewall.extraInputRules = ''
    ip saddr 192.168.0.0/16 tcp dport 1883 accept
  '';
  systemd = {
    services."light-temp" = {
      wantedBy = [ "mosquitto.service" ];
      requisite = [ "mosquitto.service" ];
      after = [ "mosquitto.service" ];
      serviceConfig.Type = "oneshot";
      startAt = [ "*-*-* 8:00:00" "*-*-* 20:00:00" ];
      path = with pkgs; [ coreutils mqttui ];
      script = ''
        set -eu
        curr_time=$(date +%H:%M)
        if [[ "$curr_time" > "08:00" ]] && [[ "$curr_time" < "20:00" ]]; then
          bulb_msg='{"color_temp":150,"brightness":256}'
        else
          bulb_msg='{"color_temp":300,"brightness":220}'
        fi
        for bulb in kauf-bulb-df30ae kauf-bulb-df31f3; do
          mqttui publish -r "home/bulb/$bulb/light/kauf_bulb/command" "$bulb_msg"
        done
      '';
    };
  };
}
