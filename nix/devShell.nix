# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
pkgs: with pkgs; {
  stdenv = pkgs.stdenvNoCC;
  packages = [ mqttui b4 ];
}
