{ config, pkgs, lib, ... }: {
  home = {
    username = "archit";
    homeDirectory = "/home/archit";
    stateVersion = "22.05";
    packages = with pkgs; [
      v4l-utils
      aspell
      aspellDicts.en
      ripgrep
      fd
      tree
      fish
      clang-tools
      rust-analyzer
      zls
      jq
      nixfmt
    ];
    file = {
      ".config/emacs" = {
        source = ./emacs;
        recursive = true;
      };
      ".librewolf" = {
        source = ./librewolf;
        recursive = true;
      };
      ".ssh/config".source = ./ssh/config;
      ".config/mpv".source = ./mpv;
      ".config/zls.json".source = ./zls/zls.json;
    };
  };

  programs = {
    home-manager.enable = true;
    man.generateCaches = true;
    bash = {
      enable = true;
      initExtra = ''
        if [[ "$INSIDE_EMACS" = 'vterm' ]] \
            && [[ -n ''${EMACS_VTERM_PATH} ]] \
            && [[ -f ''${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh ]]; then
            source ''${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh
        fi
      '';
    };
    emacs = {
      enable = true;
      package = pkgs.emacs-overlay.emacsPgtkNativeComp;
      extraPackages = epkgs:
        with epkgs; [
          meow
          gcmh
          svg-lib
          rainbow-delimiters
          flyspell-correct
          which-key
          rg
          corfu
          corfu-doc
          cape
          kind-icon
          vertico
          orderless
          marginalia
          consult
          vterm
          fish-completion
          magit
          magit-todos
          hl-todo
          virtual-comment
          rmsbolt
          eglot
          yasnippet
          markdown-mode
          clang-format
          cmake-mode
          rust-mode
          cargo
          zig-mode
          scad-mode
          nix-mode
          toml-mode
          yaml-mode
          git-modes
          pdf-tools
          rainbow-mode
        ];
    };
    git = {
      enable = true;
      extraConfig = {
        pull = { ff = "only"; };
        user = { useConfigOnly = true; };
      };
      ignores = [ "/.evc" ];
    };
    zathura = {
      enable = true;
      options = {
        recolor = true;
        recolor-keephue = true;
      };
    };
    less = {
      enable = true;
      keys = ''
        #env
        LESS = -i -R
      '';
    };
    mpv = {
      enable = true;
      scripts = [ pkgs.mpvScripts.mpris pkgs.mpvScripts.sponsorblock ];
    };
  };

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
    "org/gnome/desktop/peripherals/touchpad" = { speed = 0.4; };
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
    "org/gnome/desktop/session" = { idle-delay = mkUint32 300; };
    "org/gnome/desktop/wm/preferences" = { resize-with-right-button = true; };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = mkUint32 4226;
    };
    "org/gnome/nautilus/preferences" = { show-delete-permanently = true; };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = 1800;
      sleep-inactive-battery-timeout = 900;
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        native-window-placement.extensionUuid
        system-action-hibernate.extensionUuid
      ];
      favorite-apps = [
        "emacsclient.desktop"
        "librewolf.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };
    "org/gnome/system/location" = { enabled = true; };
    "org/gtk/settings/file-chooser" = { clock-format = "12h"; };
  };
}
