# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (builtins) mapAttrs readFile;
  inherit (lib)
    getExe
    ;
  inherit (inputs) self;
in
{
  imports = with self.homeModules; [
    common
    gnome
  ];

  home = {
    stateVersion = "25.11";
    sessionVariables = {
      BROWSER = "librewolf";
      DICTDIR = "${pkgs.hunspellDicts.en_US}/share/hunspell";
      CODEX_HOME = "${config.xdg.stateHome}/codex";
    };
    packages = with pkgs; [
      emacsAccelbread
      hunspellDicts.en_US
      rsgain
      flac
      yubikey-manager
      yubico-piv-tool
      librewolf
      android-tools
    ];
    gui-packages = with pkgs; [
      thunderbird
      fractal
      gimp3
      libreoffice
      celluloid
      amberol
      fragments
      gnome-decoder
      eyedropper
      d-spy
      firefox
      ungoogled-chromium
      rnote
      inkscape
      foliate
      warp
    ];
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
              aws ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/pass
          fi
          $DRY_RUN_CMD ${pkgs.pass}/bin/pass git remote set-url \
            aws ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos/pass
          $DRY_RUN_CMD ${pkgs.pass}/bin/pass git config remote.pushDefault aws
          $DRY_RUN_CMD ${pkgs.pass}/bin/pass git config pass.signcommits true
          $DRY_RUN_CMD ${pkgs.pass}/bin/pass git config user.signingkey \
            "$PASSWORD_STORE_SIGNING_KEY"
        '';
    };
  };

  systemd.user.services = {
    set-album-arts = {
      Unit.Description = "Set album arts";
      Install.WantedBy = [ "graphical-session.target" ];
      Service.ExecStart = getExe (
        pkgs.writeShellApplication {
          name = "set-album-arts";
          runtimeInputs = [
            pkgs.glib
            pkgs.ffmpeg-headless
          ];
          text = readFile ./scripts/set-album-arts;
        }
      );
    };
    local-api-proxy = {
      Unit = {
        Description = "Local proxy for authenticated APIs";
        After = [
          "graphical-session.target"
          "dbus.socket"
        ];
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = getExe (
          pkgs.writeShellApplication {
            name = "local-api-proxy";
            runtimeInputs = [
              pkgs.caddy
              pkgs.libsecret
            ];
            text = readFile ./scripts/local-api-proxy;
          }
        );
        Restart = "on-failure";
        RestartSec = 5;
      };
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
  };

  fonts.fontconfig.enable = false;

  xdg = {
    desktopEntries.cups = {
      name = "";
      exec = null;
      settings.Hidden = "true";
    };
  };
}
