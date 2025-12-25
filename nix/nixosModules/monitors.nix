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
    systemd.tmpfiles.rules = [
      "L+ /run/gdm/.config/monitors.xml - gdm gdm - ${monitors}"
    ];
    home-manager.sharedModules = [
      ({ lib, ... }: {
        home.activation.monitorsDefaults =
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            $DRY_RUN_CMD mkdir -p "$HOME/.config"
            $DRY_RUN_CMD cat ${monitors} > "$HOME/.config/monitors.xml"
          '';
      })
    ];
  };
}
