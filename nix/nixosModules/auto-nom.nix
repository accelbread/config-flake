# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ config, lib, pkgs, ... }:
{
  environment.systemPackages = lib.singleton
    (lib.hiPrio (pkgs.nixNomWrappers.override {
      nix = config.nix.package;
      nixos-rebuild-ng = config.system.build.nixos-rebuild;
    }));
}
