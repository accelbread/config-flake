# hello-world -- Template C application
# Copyright (C) 2023 Archit Gupta <archit@accelbread.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: AGPL-3.0-or-later

{
  description = "Template C application.";
  inputs.flakelight.url = "github:accelbread/flakelight";
  outputs = { flakelight, ... }: flakelight ./. {
    pname = "hello-world";
    license = "AGPL-3.0-or-later";

    package = { lib, stdenv, defaultMeta }:
      stdenv.mkDerivation {
        name = "hello-world";
        src = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.fileFilter
            (file: file.name == "GNUmakefile"
              || lib.any file.hasExt [ "c" "h" ]) ./.;
        };
        installFlags = [ "DESTDIR=$(out)" ];
        meta = defaultMeta;
      };

    devShell.packages = pkgs: with pkgs; [ clang-tools coreutils ];

    formatters = {
      "*.c" = "clang-format -i";
      "*.h" = "clang-format -i";
    };
  };
}
