{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.usbguard;
in
{
  options.services.usbguard.dbus = {
    enable = mkEnableOption "USBGuard dbus daemon";
    group = mkOption {
      type = types.str;
      default = head cfg.IPCAllowedGroups;
      description = ''
        Which group to use to allow access to the USBGuard dbus service.
      '';
    };
  };

  config = mkIf (cfg.enable && cfg.dbus.enable) {
    systemd.services.usbguard-dbus = {
      description = "USBGuard D-Bus Service";
      wantedBy = [ "multi-user.target" ];
      requires = [ "usbguard.service" ];
      serviceConfig = {
        Type = "dbus";
        BusName = "org.usbguard1";
        ExecStart = "${pkgs.usbguard}/bin/usbguard-dbus --system";
        Restart = "on-failure";
      };
      aliases = [ "dbus-org.usbguard.service" ];
    };

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if ((action.id == "org.usbguard.Policy1.listRules" ||
               action.id == "org.usbguard.Policy1.appendRule" ||
               action.id == "org.usbguard.Policy1.removeRule" ||
               action.id == "org.usbguard.Devices1.applyDevicePolicy" ||
               action.id == "org.usbguard.Devices1.listDevices" ||
               action.id == "org.usbguard1.getParameter" ||
               action.id == "org.usbguard1.setParameter") &&
              subject.active == true && subject.local == true &&
              subject.isInGroup("${cfg.dbus.group}")) {
                  return polkit.Result.YES;
          }
      });
    '';
  };
}
