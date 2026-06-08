{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  inherit (config.sysconfig) monitors;
in
{
  options.sysconfig.monitors = mkOption {
    type = types.nullOr types.path;
    default = { };
    description = "monitors.xml config.";
  };

  config = lib.mkIf (monitors != null) {
    environment.etc."xdg/monitors.xml".source = monitors;
  };
}
