{ config, pkgs, lib, ... }:
let
  inherit (builtins) mapAttrs;
  self = ../..;
in
{
  imports = [ ./. ./dconf.nix ];
  home = {
    stateVersion = "22.05";
    packages = with pkgs; [
      librewolf
      v4l-utils
      helvum
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
