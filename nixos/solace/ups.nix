{ config, pkgs, ... }:
let
  sudo = "/run/wrappers/bin/sudo";
  poweroff = "/run/current-system/sw/bin/poweroff";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  notifycmd = pkgs.writeShellScript "nut-notifycmd" ''
    ${sudo} -u archit \
      DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
      ${notify-send} -c critical "$1"
  '';
in
{
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
      "nut/upsmon.conf".text =
        ''
          SHUTDOWNCMD "${sudo} ${poweroff}"
          NOTIFYCMD ${notifycmd}
          NOTIFYFLAG ONLINE SYSLOG+EXEC
          NOTIFYFLAG ONBATT SYSLOG+EXEC
          NOTIFYFLAG FSD SYSLOG+EXEC
          NOTIFYFLAG COMMOK SYSLOG+EXEC
          NOTIFYFLAG COMMBAD SYSLOG+EXEC
          NOTIFYFLAG SHUTDOWN SYSLOG+EXEC
          NOTIFYFLAG REPLBATT SYSLOG+EXEC
          NOTIFYFLAG NOCOMM SYSLOG+EXEC
          MONITOR desk 1 monuser upsmon_pass master
        '';
    };
  };

  security.sudo.extraConfig = ''
    nut ALL=(root) NOPASSWD: ${poweroff}
    nut ALL=(archit) NOPASSWD: SETENV: ${notify-send}
  '';
}

