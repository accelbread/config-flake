# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib
, guile
, nix
, nix-output-monitor
, nixos-rebuild-ng ? null
, bash
, replaceVarsWith
}:
let
  nixos-rebuild = lib.optionalString (nixos-rebuild-ng != null) "nixos-rebuild";
in
replaceVarsWith {
  name = "nix-nom-wrappers";
  src = ./misc/nix-nom.scm;
  replacements = {
    inherit guile nix nix-output-monitor nixos-rebuild-ng bash;
  };
  dir = "libexec";
  isExecutable = true;

  postBuild = ''
    mkdir -p $out/bin
    for wrapper in nix nix-build nix-shell ${nixos-rebuild}; do
      ln -s ../libexec/$name $out/bin/$wrapper
    done
  '';
}
