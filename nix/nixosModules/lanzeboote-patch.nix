# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{ inputs, lib, ... }:
let
  file = "${inputs.lanzaboote}/nix/modules/lanzaboote.nix";
  line = "assertion = !cfg.autoEnrollKeys.allowBrickingMyMachine -> cfg.autoEnrollKeys.includeMicrosoftKeys;";
in
{
  disabledModules = [ file ];
  imports =
    builtins.readFile file
    |> (f: lib.throwIfNot (lib.hasInfix line f) "Patch line missing" f)
    |> builtins.replaceStrings [ line ] [ "assertion = true;" ]
    |> builtins.toFile "lanzaboote.nix"
    |> lib.singleton;
}
