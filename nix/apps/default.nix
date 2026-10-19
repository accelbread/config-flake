# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  src,
  nixVersions,
  writeShellScript,
  emacsAccelbread,
  bubblewrap,
  firefox,
  ...
}:
let
  nix = ''${nixVersions.latest}/bin/nix --extra-experimental-features "${
    lib.concatStringsSep " " [
      "nix-command"
      "flakes"
      "ca-derivations"
      "pipe-operators"
    ]
  }"'';
in
rec {
  default = emacs;
  emacs = writeShellScript "emacsWithConfig" ''
    set -eu
    emacs_dir=$(mktemp -d)
    cleanup() { rm -rf "$emacs_dir"; }
    trap cleanup EXIT
    ${emacsAccelbread}/bin/emacs --init-directory="$emacs_dir" "$@"
  '';

  system = writeShellScript "run-system-action" ''
    set -eu
    ref="${src}#nixosConfigurations.$1.config.ab.systemActions.$2"
    ${nix} build --no-link "$ref"
    script=$(${nix} eval --raw "$ref")
    exec $script
  '';

  firefoxNetworkDns = writeShellScript "firefoxNetworkDns" ''
    exec ${bubblewrap}/bin/bwrap --bind / / --dev-bind /dev /dev \
      --bind /run/NetworkManager/resolv.conf /etc/resolv.conf \
      -- ${firefox}/bin/firefox
  '';
}
