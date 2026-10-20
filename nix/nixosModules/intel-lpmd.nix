# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.intel-lpmd;
in
{
  options.services.intel-lpmd = {
    enable = lib.mkEnableOption "intel-lpmd";
    config-dir = lib.mkOption {
      type = lib.types.path;
      default = pkgs.runCommand "intel-lpmd-config" { } ''
        cp -r ${pkgs.intel-lpmd}/etc/intel_lpmd "$out"
        chmod -R u+w "$out"
        sed -i -E \
          -e 's|<Mode>[[:space:]]*-1[[:space:]]*</Mode>|<Mode>0</Mode>|g' \
          -e 's|<BalancedDef>[^<]*</BalancedDef>|<BalancedDef>0</BalancedDef>|g' \
          -e 's|<PowersaverDef>[^<]*</PowersaverDef>|<PowersaverDef>0</PowersaverDef>|g' \
          "$out"/intel_lpmd_config*.xml
      '';
      description = "intel-lpmd config dir.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      packages = [ pkgs.intel-lpmd ];
      services.intel_lpmd.wantedBy = [ "multi-user.target" ];
    };
    services.dbus.packages = [ pkgs.intel-lpmd ];
    environment.etc.intel_lpmd.source = cfg.config-dir;
  };
}
