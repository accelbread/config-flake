{ inputs, lib, pkgs, ... }: {
  imports = [ inputs.self.homeModules.gnome-extensions ];

  home = {
    packages = with pkgs; [
      gnome-session
    ];
    gui-packages = with pkgs; [
      dconf-editor
      helvum
    ];
  };

  gnome.extensions = with pkgs.gnomeExtensions; [ caffeine app-menu-is-back ];

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 300;
    maxCacheTtl = 1800;
    extraConfig = ''
      no-allow-external-cache
    '';
  };

  xdg = {
    mimeApps = {
      enable = true;
      associations.removed = {
        "x-scheme-handler/mailto" = [ "chromium.desktop" ];
      };
      defaultApplications = {
        "text/html" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
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
    with lib.hm.gvariant; let
      background = {
        color-shading-type = "solid";
        picture-uri = "none";
        picture-uri-dark = "none";
        primary-color = "#7767B2";
      };

      utc = mkVariant (mkTuple [
        (mkUint32 2)
        (mkVariant (mkTuple [
          "Coordinated Universal Time (UTC)"
          "@UTC"
          false
          (mkEmptyArray "(dd)")
          (mkEmptyArray "(dd)")
        ]))
      ]);
    in
    {
      "ca/desrt/dconf-editor" = {
        show-warning = false;
      };
      "io/bassi/Amberol" = {
        background-play = false;
        replay-gain = "track";
      };
      "org/gnome/Console" = {
        visual-bell = false;
      };
      "org/gnome/clocks" = {
        world-clocks = [ [ (mkDictionaryEntry [ "location" utc ]) ] ];
      };
      "org/gnome/desktop/background" = background;
      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "terminate:ctrl_alt_bksp" "compose:caps" ];
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
      "org/gnome/desktop/wm/preferences" = {
        resize-with-right-button = true;
        visual-bell = true;
        visual-bell-type = "frame-flash";
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        edge-tiling = true;
        workspaces-only-on-primary = true;
        attach-modal-dialogs = false;
      };
      "org/gnome/nautilus/preferences" = {
        show-delete-permanently = true;
      };
      "org/gnome/nautilus/list-view" = {
        use-tree-view = true;
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        favorite-apps = [
          "emacs.desktop"
          "librewolf.desktop"
          "org.gnome.Nautilus.desktop"
          "io.bassi.Amberol.desktop"
        ];
      };
      "org/gnome/shell/extensions/caffeine" = {
        show-timer = false;
      };
      "org/gnome/shell/world-clocks" = {
        locations = [ utc ];
      };
      "org/gnome/system/location" = {
        enabled = true;
      };
      "org/gtk/settings/file-chooser" = {
        clock-format = "12h";
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        sort-directories-first = false;
      };
    };
}
