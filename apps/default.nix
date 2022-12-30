self: pkgs:
let
  mkApp = program: { type = "app"; program = "${program}"; };
  nix = ''nix --extra-experimental-features "nix-command flakes"'';
in
{
  emacs = mkApp "${pkgs.emacsAccelbread}/bin/emacs";
} //
pkgs.lib.mapAttrs (_: mkApp) rec {
  nixosProvision = "${pkgs.writeShellScript "nixos-provision" ''
    set -eu
    ref="${self}#nixosConfigurations.$1.config.system.build.provisionScript"
    ${nix} build --no-link "$ref"
    script=$(${nix} eval --raw "$ref")
    sudo $script
  ''}";

  nixosMount = pkgs.writeShellScript "nixos-mount" ''
    set -eu
    ref="${self}#nixosConfigurations.$1.config.system.build.mountScript"
    ${nix} build --no-link "$ref"
    script=$(${nix} eval --raw "$ref")
    sudo $script
  '';

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
