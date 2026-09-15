# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ pkgs, lib, ... }:
let
  configDir = ../../dotfiles/emacs;
in
{
  home = {
    packages = with pkgs; [
      emacsAccelbread
      emacsAccelbread-terminfo
      emacs-eat-terminfo
    ];
    file.".config/emacs" = {
      source = lib.fileset.toSource {
        root = configDir;
        fileset = lib.fileset.difference configDir (configDir + "/user-lisp");
      };
      recursive = true;
    };
  };

  programs.git.ignores = [ "/.evc" ".direnv" ];

  xdg.desktopEntries = builtins.foldl'
    (a: v: a // {
      ${v} = { name = ""; exec = null; settings.Hidden = "true"; };
    })
    { }
    [ "emacsclient" "emacs-mail" "emacsclient-mail" ]
  // {
    emacs = {
      name = "Emacs";
      mimeType = [ "text/english" "text/plain" ];
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
