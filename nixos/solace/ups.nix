{ config, pkgs, lib, ... }: {
  users = {
    groups.nut = { };
    users.nut = {
      description = "NUT (Network UPS Tools)";
      group = "nut";
      isSystemUser = true;
      createHome = true;
      home = "/var/lib/nut";
    };
  };

  services.udev.packages = [ pkgs.nut ];

  systemd = {
    packages = [ pkgs.nut ];
    services = {
      nut-server.wantedBy = [ "multi-user.target" ];
      nut-monitor.wantedBy = [ "multi-user.target" ];
    };
  };

  environment = {
    etc = {
      "nut/nut.conf".text = ''
        MODE = standalone
      '';
      "nut/ups.conf".text = ''
        [desk]
        driver = usbhid-ups
        port = auto
      '';
    } // builtins.mapAttrs (_: v: v // { mode = "0640"; group = "nut"; }) {
      "nut/upsd.conf".text = "";
      "nut/upsd.users".text = ''
        [monuser]
        password = upsmon_pass
        upsmon master
      '';
      "nut/upsmon.conf".text = ''
        MONITOR desk 1 monuser upsmon_pass master
      '';
    };
  };
}

