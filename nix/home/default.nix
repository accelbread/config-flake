{ config, pkgs, lib, ... }:
let
  inherit (builtins) mapAttrs;
  self = ../..;
in
{
  imports = [ ./emacs.nix ./dconf.nix ];
  home = {
    stateVersion = "22.05";
    sessionVariables = {
      TPM2_PKCS11_STORE = "$HOME/.local/share/tpm2_pkcs11";
      TSS2_LOG = "fapi+NONE";
    };
    packages = with pkgs; [
      librewolf
      zeal
      v4l-utils
      gnome.gnome-session
      gnomeExtensions.espresso
      gnomeExtensions.system-action-hibernate
    ];
    file = mapAttrs (_: v: v // { recursive = true; }) {
      ".config".source = self + /dotfiles/config;
      ".librewolf".source = self + /dotfiles/librewolf;
      ".ssh".source = self + /dotfiles/ssh;
    };
  };

  programs = mapAttrs (_: v: v // { enable = true; }) {
    home-manager = { };
    man.generateCaches = true;
    bash.initExtra = ''
      if [[ -z "$LS_COLORS" ]]; then
          eval "$(${pkgs.coreutils}/bin/dircolors -b)"
      fi
    '';
    git.extraConfig = {
      pull.ff = "only";
      user.useConfigOnly = true;
    };
    gpg.homedir = "${config.xdg.dataHome}/gnupg";
    password-store = {
      package = pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_CLIP_TIME = "10";
        PASSWORD_STORE_GENERATED_LENGTH = "16";
        PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
        PASSWORD_STORE_SIGNING_KEY = "570BE31ADF804E920FD226321F90781ED8448A79";
      };
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

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  xdg.desktopEntries = {
    cups = { name = ""; exec = null; settings.Hidden = "true"; };
  };
}
