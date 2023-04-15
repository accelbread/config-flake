pkgs:
let
  inherit (pkgs.flakelite.inputs) self;
  nix = ''nix --extra-experimental-features "nix-command flakes"'';
  mkBuildScript = script: pkgs.writeShellScript script ''
    set -eu
    ref="${self}#nixosConfigurations.$1.config.system.build.${script}"
    ${nix} build --no-link "$ref"
    script=$(${nix} eval --raw "$ref")
    sudo $script
  '';
in
rec {
  emacs = "${pkgs.emacsAccelbread}/bin/emacs";

  nixosProvision = mkBuildScript "provisionScript";
  nixosMount = mkBuildScript "mountScript";
  nixosUnmount = mkBuildScript "unmountScript";
  nixosInstall = pkgs.writeShellScript "nixos-install" ''
    set -eu
    sudo nixos-install --no-root-passwd --flake ${self}#$1
  '';
  nixosFullInstall = pkgs.writeShellScript "nixos-fullinstall" ''
    set -xeu
    ${nixosProvision} $1
    ${nixosMount} $1
    ${nixosInstall} $1
  '';
}
