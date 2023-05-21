{ pkgs, lib, config, ... }:
with lib;
let
  inherit (builtins) fromJSON readFile toFile toJSON unsafeDiscardStringContext;
  inherit (lib) pipe removePrefix;

  cfg = config.security.tpm2;
  tctiCfg = cfg.tctiEnvironment;

  pkg = pkgs.tpm2-tss;
  tctiOption =
    if tctiCfg.interface == "tabrmd" then
      tctiCfg.tabrmdConf else tctiCfg.deviceConf;
in
{
  config = mkIf (cfg.enable && tctiCfg.enable) {
    environment.variables.TSS2_FAPICONF =
      pipe (pkg + /etc/tpm2-tss/fapi-config.json) [
        readFile
        unsafeDiscardStringContext
        fromJSON
        (prev: prev // {
          system_dir = removePrefix "${pkg}" prev.system_dir;
          log_dir = removePrefix "${pkg}" prev.log_dir;
          tcti = "${tctiCfg.interface}:${tctiOption}";
        })
        toJSON
        (toFile "fapi-config.json")
      ];
  };
}
