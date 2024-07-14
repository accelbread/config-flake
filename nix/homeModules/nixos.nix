{ config, pkgs, lib, inputs, ... }:
let
  inherit (builtins) mapAttrs;
  inherit (inputs) self;
in
{
  imports = with self.homeModules; [ common gnome ];

  home = {
    stateVersion = "23.11";
    sessionVariables = {
      BROWSER = "librewolf";
      GDK_DPI_SCALE = "1.25";
      QT_SCALE_FACTOR = "1.25";
      TPM2_PKCS11_STORE = "$HOME/.local/share/tpm2_pkcs11";
      TSS2_LOG = "fapi+NONE";
      DICTDIR = "${pkgs.hunspellDicts.en_US}/share/hunspell";
    };
    packages = with pkgs; [
      hunspellDicts.en_US
    ];
    gui-packages = with pkgs; [
      (librewolf.override {
        nativeMessagingHosts = [
          (passff-host.override {
            pass = config.programs.password-store.package;
          })
        ];
      })
      gimp
      libreoffice
      amberol
      cockatrice
    ];
    file = mapAttrs (_: v: { recursive = true; } // v) {
      ".face".source = self + /misc/icon.png;
      ".config".source = self + /dotfiles/config;
      ".ssh".source = self + /dotfiles/ssh;
      ".librewolf".source = self + /dotfiles/librewolf;
      ".librewolf/profile/chrome/firefox-gnome-theme" = {
        source = pkgs.firefox-gnome-theme;
        recursive = false;
      };
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
              text = builtins.readFile ./scripts/tpm2-pkcs11-init;
            })
          }
        '';
    };
  };

  systemd.user.services.set-album-arts = {
    Unit.Description = "Set album arts";
    Install.WantedBy = [ "graphical-session.target" ];
    Service.ExecStart = "${
      lib.getExe (pkgs.writeShellApplication {
        name = "set-album-arts";
        runtimeInputs = [ pkgs.glib ];
        text = builtins.readFile ./scripts/set-album-arts;
      })
    }";
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
  };

  xdg.desktopEntries.cups =
    { name = ""; exec = null; settings.Hidden = "true"; };
}
