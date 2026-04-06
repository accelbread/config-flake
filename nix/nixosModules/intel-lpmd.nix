{ config, lib, pkgs, ... }:
let
  cfg = config.services.intel-lpmd;
in
{
  options.services.intel-lpmd = {
    enable = lib.mkEnableOption "intel-lpmd";
    config-dir = lib.mkOption {
      type = lib.types.path;
      default = pkgs.intel-lpmd + /etc/intel_lpmd;
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
