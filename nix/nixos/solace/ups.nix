{ pkgs, ... }:
let
  notify-send = pkgs.writeShellScript "notify-send-wrapper" ''
    DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
      ${pkgs.libnotify}/bin/notify-send "$@"
  '';
  notifycmd = pkgs.writeShellScript "nut-notifycmd" ''
    /run/wrappers/bin/pkexec --user archit ${notify-send} -u critical "$1"
  '';
in
{
  systemd.services = {
    upsdrv = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.nut}/bin/upsdrvctl -u nut start";
      };
    };
    upsd = {
      after = [ "network.target" "upsdrv.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.nut}/sbin/upsd -u nut";
      };
    };
    upsmon = {
      after = [ "network.target" "upsd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.nut}/sbin/upsmon -u nut";
      };
    };
    ups-killpower = {
      wantedBy = [ "shutdown.target" ];
      after = [ "shutdown.target" ];
      before = [ "final.target" ];
      unitConfig = {
        ConditionPathExists = "/run/killpower";
        DefaultDependencies = "no";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.nut}/bin/upsdrvctl shutdown";
      };
    };
  };

  environment.etc = {
    "nut/nut.conf".source = pkgs.writeText "nut.conf" ''
      MODE = standalone
    '';
    "nut/ups.conf".source = pkgs.writeText "ups.conf" ''
      [desk]
      driver = usbhid-ups
      port = auto
    '';
    "nut/upsd.conf".source = pkgs.writeText "upsd.conf" ''
    '';
    "nut/upsd.users".source = pkgs.writeText "upsd.users" ''
      [monuser]
      password = "upsmon_pass"
      upsmon primary
    '';
    "nut/upsmon.conf".source = pkgs.writeText "upsmon.conf" ''
      RUN_AS_USER nut
      POWERDOWNFLAG /run/killpower
      MONITOR desk 1 monuser "upsmon_pass" primary
      SHUTDOWNCMD /run/current-system/sw/bin/poweroff
      NOTIFYCMD ${notifycmd}
      NOTIFYFLAG ONLINE SYSLOG+EXEC
      NOTIFYFLAG ONBATT SYSLOG+EXEC
      NOTIFYFLAG FSD SYSLOG+EXEC
      NOTIFYFLAG COMMOK SYSLOG+EXEC
      NOTIFYFLAG COMMBAD SYSLOG+EXEC
      NOTIFYFLAG SHUTDOWN SYSLOG+EXEC
      NOTIFYFLAG REPLBATT SYSLOG+EXEC
      NOTIFYFLAG NOCOMM SYSLOG+EXEC
    '';
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

  security.polkit = {
    enable = true;
    extraConfig = builtins.replaceStrings
      [ "@notify_prog@" ] [ "${notify-send}" ]
      (builtins.readFile ./polkit-nut.js);
  };
}
