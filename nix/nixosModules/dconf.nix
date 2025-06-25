{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.sysconfig.dconf = mkOption {
    type = types.lazyAttrsOf (types.attrs);
    default = { };
    description = "Global dconf configuration.";
  };

  config.programs.dconf.profiles = {
    user.databases = [{ settings = config.sysconfig.dconf; }];
    gdm.databases = [{ settings = config.sysconfig.dconf; }];
  };
}
