{ lib, pkgs, ... }: {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri =
        "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      picture-uri-dark =
        "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-d.jpg";
      primary-color = "#3465a4";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "terminate:ctrl_alt_bksp" "compose:caps" ];
    };
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      font-antialiasing = "rgba";
      font-hinting = "slight";
      locate-pointer = true;
    };
    "org/gnome/desktop/media-handling" = { autorun-never = true; };
    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
      remember-recent-files = false;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };
    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      lock-delay = mkUint32 30;
      picture-options = "zoom";
      picture-uri =
        "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      primary-color = "#3465a4";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/session" = { idle-delay = mkUint32 180; };
    "org/gnome/desktop/wm/preferences" = { resize-with-right-button = true; };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = mkUint32 4226;
    };
    "org/gnome/nautilus/preferences" = { show-delete-permanently = true; };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        native-window-placement.extensionUuid
        espresso.extensionUuid
        system-action-hibernate.extensionUuid
        gsconnect.extensionUuid
      ];
      favorite-apps = [
        "emacs.desktop"
        "librewolf.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };
    "org/gnome/system/location" = { enabled = true; };
    "org/gtk/settings/file-chooser" = { clock-format = "12h"; };
  };
}
