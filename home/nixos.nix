{ config, pkgs, lib, ... }:
let
  inherit (builtins) mapAttrs;
  self = ../.;
in
{
  imports = [ ./common.nix ./dconf.nix ./gsconnect.nix ];

  home = {
    stateVersion = "22.05";
    sessionVariables = {
      BROWSER = "librewolf";
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
      MOZ_X11_EGL = "1";
      GDK_DPI_SCALE = "1.25";
      QT_SCALE_FACTOR = "1.25";
    };
    packages = with pkgs; [
      librewolf
      v4l-utils
      helvum
      easyeffects
      gnome.gnome-session
      gnome.dconf-editor
      gnomeExtensions.espresso
      git-annex
      cockatrice
    ];
    file = mapAttrs (_: v: v // { recursive = true; }) {
      ".config".source = self + /dotfiles/config;
      ".ssh".source = self + /dotfiles/ssh;
      ".librewolf".source = self + /dotfiles/librewolf;
      ".librewolf/profile/chrome/firefox-vertical-tabs.css".source =
        pkgs.firefox-vertical-tabs + /userChrome.css;
    };
    activation.configureFlathub =
      let flatpak = "${pkgs.flatpak}/bin/flatpak"; in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${flatpak} --user remote-add --if-not-exists $VERBOSE_ARG \
          flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
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
      };
    };
    configFile."mimeapps.list".force = true;
    desktopEntries.cups = { name = ""; exec = null; settings.Hidden = "true"; };
  };
}
