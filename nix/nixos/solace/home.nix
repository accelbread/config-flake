{ lib, pkgs, ... }: {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };
  };
}
