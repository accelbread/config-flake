{ lib, ... }: {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/peripherals/touchpad" = { speed = 0.6; };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };
    "org/gnome/shell/extensions/gsconnect" = {
      id = "0acf5e7b-de24-425b-8cb9-ab00a8c5bc7f";
      name = "solace";
    };
  };
}
