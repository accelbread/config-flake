{ pkgs, lib, config, ... }:
with lib;
let
  inherit (builtins) fromJSON readFile toFile toJSON unsafeDiscardStringContext;
  inherit (lib.strings) removePrefix;

  cfg = config.security.tpm2;
  tctiCfg = cfg.tctiEnvironment;
in
{
  config = mkIf (cfg.enable && tctiCfg.enable) (
    let
      tctiOption =
        if tctiCfg.interface == "tabrmd" then
          tctiCfg.tabrmdConf else tctiCfg.deviceConf;
      pkg = pkgs.tpm2-tss;
      defaultCfgFile = pkg + /etc/tpm2-tss/fapi-config.json;
      defaultCfg = fromJSON (unsafeDiscardStringContext
        (readFile defaultCfgFile));
      fixedCfg = defaultCfg // {
        system_dir = removePrefix "${pkg}" defaultCfg.system_dir;
        log_dir = removePrefix "${pkg}" defaultCfg.log_dir;
        tcti = "${tctiCfg.interface}:${tctiOption}";
      };
      fixedCfgFile = toFile "fapi-config.json" (toJSON fixedCfg);
    in
    {
      environment.variables.TSS2_FAPICONF = fixedCfgFile;
    }
  );
}
