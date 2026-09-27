# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ config, lib, ... }:
let
  inherit (lib) catAttrs mkOption types;
in
{
  options.gnome.extensions = mkOption {
    type = types.listOf types.package;
    default = [ ];
    description = "Gnome extension packages to enable.";
  };

  config = {
    home.packages = config.gnome.extensions;

    dconf.settings."org/gnome/shell".enabled-extensions =
      catAttrs "extensionUuid" config.gnome.extensions;
  };
}
