# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.ab.dconf = {
    all = mkOption {
      type = types.lazyAttrsOf types.attrs;
      default = { };
      description = "Global dconf configuration.";
    };
    user = mkOption {
      type = types.lazyAttrsOf types.attrs;
      default = { };
      description = "User dconf configuration.";
    };
    gdm = mkOption {
      type = types.lazyAttrsOf types.attrs;
      default = { };
      description = "GDM dconf configuration.";
    };
  };

  config.programs.dconf.profiles = {
    user.databases = [
      { settings = config.ab.dconf.all; }
      { settings = config.ab.dconf.user; }
    ];
    gdm.databases = [
      { settings = config.ab.dconf.all; }
      { settings = config.ab.dconf.gdm; }
    ];
  };
}
