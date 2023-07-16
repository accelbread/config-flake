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
in
{
  power.ups = {
    enable = true;
    ups.desk = { driver = "usbhid-ups"; port = "auto"; };
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
    upsd.script = lib.mkForce "${pkgs.nut}/sbin/upsd -u nut";
    upsmon.script = lib.mkForce "${pkgs.nut}/sbin/upsmon -u nut";
    upsdrv.script = lib.mkForce "${pkgs.nut}/bin/upsdrvctl -u nut start";
  };

  environment.etc = builtins.mapAttrs
    (_: v: v // { mode = "0640"; group = "nut"; })
    {
      "nut/upsd.conf".text = "";
      "nut/upsd.users".text = ''
        [monuser]
        password = upsmon_pass
        upsmon master
      '';
      "nut/upsmon.conf".text = ''
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

