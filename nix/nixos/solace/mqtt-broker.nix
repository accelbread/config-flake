{
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
}
