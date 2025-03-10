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
      startAt = [ "hourly" ];
      path = with pkgs; [ coreutils mqttui ];
      script = ''
        set -eu
        curr_time=$(date +%H:%M)
        if [[ "$curr_time" > "07:59" ]] && [[ "$curr_time" < "19:59" ]]; then
          bulb_msg='{"color_temp":150,"brightness":256}'
        else
          bulb_msg='{"color_temp":300,"brightness":220}'
        fi
        for bulb in kauf-bulb-302a8e kauf-bulb-302d18; do
          mqttui publish -r "home/bulb/$bulb/light/kauf_bulb/command" "$bulb_msg"
        done
      '';
    };
  };
}
