# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
pkgs: name: scripts:
let
  inherit (pkgs) lib;
in
pkgs.symlinkJoin {
  inherit name;
  paths = [
    (pkgs.writeShellScriptBin name ''
      set -euo pipefail
      case "$1" in
        ${
          scripts
          |> lib.mapAttrsToList (
            n: v: ''
              ${lib.escapeShellArg n}) exec ${v};;
            ''
          )
          |> lib.concatStringsSep "\n"
        }
      esac
      exit 1
    '')
    (pkgs.writeTextDir "share/bash-completion/completions/${name}" ''
      complete -W ${
        scripts
        |> lib.attrNames
        |> lib.concatStringsSep " "
        |> lib.escapeShellArg
      } ${lib.escapeShellArg name}
    '')
  ];
}
