{ lib, pkgs, ... }: {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/peripherals/touchpad" = { speed = 0.4; };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = 900;
      sleep-inactive-ac-type = "hibernate";
      sleep-inactive-battery-timeout = 900;
      sleep-inactive-battery-type = "hibernate";
    };
  };
}
