{ pkgs, lib, ... }:
let
  sudo = "/run/wrappers/bin/sudo";
  poweroff = "/run/current-system/sw/bin/poweroff";
  notify-send = pkgs.writeShellScript "notify-send-wrapper" ''
    DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
      ${pkgs.libnotify}/bin/notify-send "$@"
  '';
  notifycmd = pkgs.writeShellScript "nut-notifycmd" ''
    ${sudo} -u archit ${notify-send} -c critical "$1"
  '';
  passwordFile = "${pkgs.writeText "upspass" "upsmon_pass"}";
in
{
  power.ups = {
    enable = true;
    ups.desk = { driver = "usbhid-ups"; port = "auto"; };
    users.monuser = {
      upsmon = "master";
      inherit passwordFile;
    };
    upsmon = {
      monitor.desk = {
        user = "monuser";
        type = "master";
        inherit passwordFile;
      };
      settings = {
        RUN_AS_USER = lib.mkForce "nut";
        SHUTDOWNCMD = "${sudo} ${poweroff}";
        NOTIFYCMD = "${notifycmd}";
        NOTIFYFLAG = [
          [ "ONLINE" "SYSLOG+EXEC" ]
          [ "ONBATT" "SYSLOG+EXEC" ]
          [ "FSD" "SYSLOG+EXEC" ]
          [ "COMMOK" "SYSLOG+EXEC" ]
          [ "COMMBAD" "SYSLOG+EXEC" ]
          [ "SHUTDOWN" "SYSLOG+EXEC" ]
          [ "REPLBATT" "SYSLOG+EXEC" ]
          [ "NOCOMM" "SYSLOG+EXEC" ]
        ];
      };
    };
  };

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

  systemd.services = {
    upsd.serviceConfig.ExecStart =
      lib.mkForce "${pkgs.nut}/sbin/upsd -u nut";
    upsmon.serviceConfig.ExecStart =
      lib.mkForce "${pkgs.nut}/sbin/upsmon -u nut";
    upsdrv.serviceConfig.ExecStart =
      lib.mkForce "${pkgs.nut}/bin/upsdrvctl -u nut start";
  };

  security.sudo.extraRules = [
    {
      users = [ "nut" ];
      runAs = "root";
      commands = [{ command = "${poweroff}"; options = [ "NOPASSWD" ]; }];
    }
    {
      users = [ "nut" ];
      runAs = "archit";
      commands = [{ command = "${notify-send}"; options = [ "NOPASSWD" ]; }];
    }
  ];
}

