{ inputs, lib, pkgs, ... }: {
  imports = [ inputs.self.homeModules.gnome-extensions ];

  home = {
    packages = with pkgs; [
      gnome.gnome-session
    ];
    gui-packages = with pkgs; [
      gnome.dconf-editor
      helvum
      jamesdsp
    ];
  };

  gnome.extensions = with pkgs.gnomeExtensions; [ caffeine app-menu-is-back ];

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    defaultCacheTtl = 300;
    maxCacheTtl = 1800;
    extraConfig = ''
      no-allow-external-cache
    '';
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "audio/mpeg" = "io.bassi.Amberol.desktop";
        "audio/flac" = "io.bassi.Amberol.desktop";
      };
    };
    configFile."mimeapps.list".force = true;
  };

  dconf.settings =
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
    with lib.hm.gvariant; {
      "ca/desrt/dconf-editor" = {
        show-warning = false;
      };
      "io/bassi/Amberol" = {
        background-play = false;
        replay-gain = "album";
      };
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
        automount = false;
        autorun-never = true;
      };
      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
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
      "org/gnome/desktop/search-providers" = {
        disabled = [ "org.gnome.Software.desktop" "org.gnome.Epiphany.desktop" ];
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
        favorite-apps = [
          "emacs.desktop"
          "librewolf.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };
      "org/gnome/shell/extensions/caffeine" = {
        show-timer = false;
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
