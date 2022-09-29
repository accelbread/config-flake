{ config, pkgs, lib, ... }:
with builtins;
with lib; {
  home = {
    username = "archit";
    homeDirectory = "/home/archit";
    stateVersion = "22.05";
    sessionVariables = {
      TPM2_PKCS11_STORE = "$HOME/.local/share/tpm2_pkcs11";
      TSS2_LOG = "fapi+NONE";
    };
    packages = with pkgs; [ aspellDicts.en ];
    file = mapAttrs (name: value: value // { recursive = true; }) {
      ".config".source = ./home/config;
      ".librewolf".source = ./home/librewolf;
      ".ssh".source = ./home/ssh;
    };
  };

  programs = mapAttrs (name: value: value // { enable = true; }) {
    home-manager = { };
    man.generateCaches = true;
    bash.initExtra = ''
      if [[ "$INSIDE_EMACS" = 'vterm' ]] \
          && [[ -n ''${EMACS_VTERM_PATH} ]] \
          && [[ -f ''${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh ]]; then
          source ''${EMACS_VTERM_PATH}/etc/emacs-vterm-bash.sh
      fi
    '';
    emacs = {
      package = pkgs.emacs-overlay.emacsPgtkNativeComp;
      extraPackages = epkgs:
        attrsets.attrVals (map head (filter isList (split "([-a-z]+)" (head
          (match ".*\\(setq package-selected-packages[[:space:]]+'\\(([^)]+).*"
            (readFile ./home/config/emacs/init.el)))))) epkgs ++ singleton
        (epkgs.trivialBuild {
          pname = "nix-paths";
          src = pkgs.writeText "nix-paths.el" ''
            (setq ispell-program-name "${pkgs.aspell}/bin/aspell"
                  clang-format-executable "${pkgs.clang-tools}/bin/clang-format"
                  rust-rustfmt-bin "${pkgs.rustfmt}/bin/rustfmt"
                  nix-nixfmt-bin "${pkgs.nixfmt}/bin/nixfmt"
                  fish-completion-command "${pkgs.fish}/bin/fish")
            (with-eval-after-load 'eglot
              (setq eglot-server-programs
                    '(((c++-mode c-mode) "${pkgs.clang-tools}/bin/clangd")
                      (rust-mode "${pkgs.rust-analyzer}/bin/rust-analyzer")
                      (zig-mode "${pkgs.zls}/bin/zls")
                      (nix-mode "${pkgs.rnix-lsp}/bin/rnix-lsp"))))
            (provide 'nix-paths)
          '';
        });
    };
    git = {
      extraConfig = {
        pull = { ff = "only"; };
        user = { useConfigOnly = true; };
      };
      ignores = [ "/.evc" ];
    };
    less.keys = ''
      #env
      LESS = -i -R
    '';
    readline = {
      bindings = {
        "\\C-p" = "history-search-backward";
        "\\C-n" = "history-search-forward";
      };
      variables = {
        bell-style = "visible";
        colored-stats = true;
        completion-ignore-case = true;
        completion-prefix-display-length = 4;
        mark-symlinked-directories = true;
        show-all-if-ambiguous = true;
        show-all-if-unmodified = true;
        visible-stats = true;
      };
    };
    mpv.scripts = with pkgs.mpvScripts; [ autoload mpris sponsorblock ];
  };

  xdg.desktopEntries.cups = {
    name = "Manage Printing";
    noDisplay = true;
    exec = null;
  };

  dconf.settings = with hm.gvariant; {
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
    "org/gnome/desktop/session" = { idle-delay = mkUint32 180; };
    "org/gnome/desktop/wm/preferences" = { resize-with-right-button = true; };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = mkUint32 4226;
    };
    "org/gnome/nautilus/preferences" = { show-delete-permanently = true; };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = 900;
      sleep-inactive-ac-type = "hibernate";
      sleep-inactive-battery-timeout = 900;
      sleep-inactive-battery-type = "hibernate";
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
