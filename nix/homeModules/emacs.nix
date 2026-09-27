# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ pkgs, lib, ... }:
let
  inertDesktopEntry = {
    name = "";
    exec = null;
    settings.Hidden = "true";
  };
in
{
  home = {
    packages = with pkgs; [
      emacsAccelbread
    ];
    file.".config/emacs" = {
      source = ../../dotfiles/_config/emacs;
      recursive = true;
    };
  };

  programs.git.ignores = [
    "/.evc"
    ".direnv"
  ];

  xdg.desktopEntries =
    lib.genAttrs [
      "emacsclient"
      "emacs-mail"
      "emacsclient-mail"
    ] (_: inertDesktopEntry)
    // {
      emacs = {
        name = "Emacs";
        mimeType = [
          "text/english"
          "text/plain"
        ];
        exec = "emacsclient -ca \"\" %F";
        icon = "emacs";
        startupNotify = true;
        settings.StartupWMClass = "Emacs";
        actions.new-instance = {
          name = "New Instance";
          exec = "emacs %F";
        };
      };
    };
}
