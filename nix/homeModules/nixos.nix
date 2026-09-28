# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (builtins) mapAttrs;
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
  };

  programs = mapAttrs (_: v: v // { enable = true; }) {
    gpg.homedir = "${config.xdg.dataHome}/gnupg";
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
