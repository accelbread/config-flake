{ lib, pkgs, ... }:
let
  rawGvariant = str: {
    _type = "gvariant";
    type = "";
    value = null;
    __toString = _: str;
  };

  background = {
    color-shading-type = "solid";
    picture-uri = "none";
    picture-uri-dark = "none";
    primary-color = "#7767B2";
  };
in
{
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/clocks" = {
      world-clocks = rawGvariant
        "[{'location': <(uint32 2, <('Coordinated Universal Time (UTC)', '@UTC', false, @a(dd) [], @a(dd) [])>)>}]";
    };
    "org/gnome/desktop/background" = background;
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "terminate:ctrl_alt_bksp" "compose:caps" ];
    };
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      locate-pointer = true;
    };
    "org/gnome/desktop/media-handling" = {
      autorun-never = true;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
    };
    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
      remember-recent-files = false;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };
    "org/gnome/desktop/screensaver" = background // {
      lock-delay = mkUint32 30;
    };
    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 180;
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
    };
    "org/gnome/mutter" = {
      current-workspace-only = false;
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };
    "org/gnome/nautilus/preferences" = {
      show-delete-permanently = true;
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = mkUint32 4226;
      night-light-schedule-automatic = false;
      night-light-schedule-from = 20.0;
      night-light-schedule-to = 8.0;
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        espresso.extensionUuid
        gsconnect.extensionUuid
      ];
      favorite-apps = [
        "emacs.desktop"
        "librewolf.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };
    "org/gnome/shell/world-clocks" = {
      locations = rawGvariant
        "[<(uint32 2, <('Coordinated Universal Time (UTC)', '@UTC', false, @a(dd) [], @a(dd) [])>)>]";
    };
    "org/gnome/system/location" = {
      enabled = true;
    };
    "org/gtk/settings/file-chooser" = {
      clock-format = "12h";
    };
  };
}
