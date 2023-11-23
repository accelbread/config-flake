{ config, pkgs, lib, inputs, ... }:
let
  inherit (builtins) mapAttrs;
  inherit (inputs) self;
in
{
  imports = [ ./common.nix ./dconf.nix ./gsconnect.nix ];

  home = {
    stateVersion = "23.11";
    sessionVariables = {
      BROWSER = "librewolf";
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
      MOZ_X11_EGL = "1";
      GDK_DPI_SCALE = "1.25";
      QT_SCALE_FACTOR = "1.25";
      TPM2_PKCS11_STORE = "$HOME/.local/share/tpm2_pkcs11";
      TSS2_LOG = "fapi+NONE";
    };
    packages = with pkgs; [
      gnome.gnome-session
      gnomeExtensions.caffeine
      gnomeExtensions.gsconnect
      git-annex
      hunspellDicts.en_US
    ];
    gui-packages = with pkgs; [
      gnome.dconf-editor
      librewolf
      helvum
      jamesdsp
      gimp
      libreoffice
      cockatrice
    ];
    file = mapAttrs (_: v: v // { recursive = true; }) {
      ".config".source = self + /dotfiles/config;
      ".ssh".source = self + /dotfiles/ssh;
      ".librewolf".source = self + /dotfiles/librewolf;
      ".librewolf/profile/chrome/firefox-vertical-tabs.css".source =
        pkgs.firefox-vertical-tabs + /userChrome.css;
      ".local/share/flatpak/overrides" = {
        source = self + /dotfiles/flatpak_overrides;
        force = true;
      };
    };
    activation = {
      passGitConfig =
        let
          cfg = config.programs.password-store.settings;
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          export PASSWORD_STORE_DIR="${cfg.PASSWORD_STORE_DIR}"
          export PASSWORD_STORE_SIGNING_KEY="${cfg.PASSWORD_STORE_SIGNING_KEY}"
          if [[ ! -e "$PASSWORD_STORE_DIR/.git" ]]; then
            $DRY_RUN_CMD mkdir -p "$PASSWORD_STORE_DIR"
            $DRY_RUN_CMD ${pkgs.pass}/bin/pass git init
            $DRY_RUN_CMD ${pkgs.pass}/bin/pass git remote add \
              aws ssh://codecommit/v1/repos/pass
          fi
          $DRY_RUN_CMD ${pkgs.pass}/bin/pass git config pass.signcommits true
          $DRY_RUN_CMD ${pkgs.pass}/bin/pass git config user.signingkey \
            "$PASSWORD_STORE_SIGNING_KEY"
        '';
      codecommitUsername =
        let
          default = builtins.toFile "default-codecommit-config" ''
            Host codecommit
              User <missing-username>
          '';
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [[ ! -f "$HOME/.ssh/config.d/codecommit" ]]; then
            $DRY_RUN_CMD mkdir -p "$HOME/.ssh/config.d"
            $DRY_RUN_CMD cat ${default} > "$HOME/.ssh/config.d/codecommit"
          fi
        '';
      tpm2-pkcs11 =
        let
          dir = config.home.sessionVariables.TPM2_PKCS11_STORE;
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          export TPM2_PKCS11_STORE="${dir}"
          $DRY_RUN_CMD ${
            lib.getExe (pkgs.writeShellApplication {
              name = "tpm2-pkcs11-init";
              runtimeInputs = with pkgs; [ tpm2-pkcs11 gnugrep coreutils ];
              text = builtins.readFile ./scripts/tpm2-pkcs11-init.sh;
            })
          }
        '';
    };
  };

  programs = mapAttrs (_: v: v // { enable = true; }) {
    gpg.homedir = "${config.xdg.dataHome}/gnupg";
    password-store = {
      package = pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_CLIP_TIME = "10";
        PASSWORD_STORE_GENERATED_LENGTH = "16";
        PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
        PASSWORD_STORE_SIGNING_KEY = "C4F4D63E4C22651B053D0848DE26C77562110E92";
      };
    };
    mpv.scripts = with pkgs.mpvScripts; [ autoload mpris sponsorblock ];
    git = {
      userName = "Archit Gupta";
      userEmail = "archit@accelbread.com";
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "audio/mpeg" = "umpv.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/png" = "org.gnome.eog.desktop";
        "image/jpeg" = "org.gnome.eog.desktop";
      };
    };
    configFile."mimeapps.list".force = true;
    desktopEntries.cups = { name = ""; exec = null; settings.Hidden = "true"; };
  };
}
