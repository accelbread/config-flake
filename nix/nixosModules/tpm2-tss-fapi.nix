{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.security.tpm2;
  tctiCfg = cfg.tctiEnvironment;

  pkg = pkgs.tpm2-tss;
  tctiOption =
    if tctiCfg.interface == "tabrmd" then
      tctiCfg.tabrmdConf else tctiCfg.deviceConf;
  tcti = "${tctiCfg.interface}:${tctiOption}";
in
{
  config = mkIf (cfg.enable && tctiCfg.enable) {
    environment.sessionVariables = {
      TSS2_FAPICONF = pkgs.runCommand "fapi-config.json" { } ''
        cp ${pkg}/etc/tpm2-tss/fapi-config.json $out
        sed -i 's|/nix/store/[^/]*/var|/var|' $out
        sed -i 's|"tcti":.*$|"tcti": "${tcti}",|' $out
      '';
      TPM2TOOLS_TCTI = tcti;
      TPM2_PKCS11_TCTI = tcti;
    };
  };
}
