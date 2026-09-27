# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ pkgs, ... }:
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
}
