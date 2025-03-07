{ src, writeShellScript, emacsAccelbread, bubblewrap, firefox, ... }:
let
  nix = ''nix --extra-experimental-features "nix-command flakes"'';
  mkBuildScript = script: writeShellScript script ''
    set -eu
    ref="${src}#nixosConfigurations.$1.config.system.build.${script}"
    ${nix} build --no-link "$ref"
    script=$(${nix} eval --raw "$ref")
    sudo $script
  '';
in
rec {
  default = emacs;
  emacs = writeShellScript "emacsWithConfig" ''
    set -eu
    emacs_dir=$(mktemp -d)
    cleanup() { rm -rf "$emacs_dir"; }
    trap cleanup EXIT
    cp --no-preserve=all -rT "${src + /dotfiles/emacs}" "$emacs_dir"
    ${emacsAccelbread}/bin/emacs --init-directory="$emacs_dir" "$@"
  '';

  nixosProvision = mkBuildScript "provisionScript";
  nixosMount = mkBuildScript "mountScript";
  nixosUnmount = mkBuildScript "unmountScript";
  nixosInstall = writeShellScript "nixos-install" ''
    set -eu
    sudo nixos-install --no-root-passwd --flake ${src}#$1
  '';
  nixosFullInstall = writeShellScript "nixos-fullinstall" ''
    set -xeu
    ${nixosProvision} $1
    ${nixosMount} $1
    ${nixosInstall} $1
  '';

  firefoxNetworkDns = writeShellScript "firefoxNetworkDns" ''
    exec ${bubblewrap}/bin/bwrap --bind / / --dev-bind /dev /dev \
      --bind /run/NetworkManager/resolv.conf /etc/resolv.conf \
      -- ${firefox}/bin/firefox
  '';
}
