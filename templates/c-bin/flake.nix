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
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
  };
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      eachSystem = with nixpkgs.lib; f: foldAttrs mergeAttrs { }
        (map (s: mapAttrs (_: v: { ${s} = v; }) (f s)) systems);
    in
    eachSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;
        runCheck = cmd: pkgs.runCommand "check" { }
          "cp --no-preserve=mode -r ${./.} src; cd src\n${cmd}\ntouch $out";
        formatters = with pkgs; [
          clang-tools
          coreutils
          nixpkgs-fmt
          nodePackages.prettier
        ];
      in
      rec {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "hello-world";
          src = ./.;
          installPhase = ''
            runHook preInstall
            make DESTDIR=$out install
            runHook postInstall
          '';
          meta = with pkgs.lib; {
            description = "Template C application.";
            license = licenses.agpl3Plus;
            platforms = platforms.linux;
          };
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ packages.default ];
          packages = with pkgs; [ clang-tools ] ++ formatters;
        };
        checks = {
          package = packages.default;
          formatting = runCheck ''
            ${lib.getExe formatter} .
            ${pkgs.diffutils}/bin/diff -qr ${./.} . |\
              sed 's/Files .* and \(.*\) differ/File \1 not formatted/g'
          '';
        };
        formatter = pkgs.writeShellScriptBin "formatter" ''
          PATH=${lib.makeBinPath formatters}
          for f in "$@"; do case "$f" in
            *.c | *.h) clang-format -i "$f";;
            *.nix) nixpkgs-fmt "$f";;
            *.md) prettier --write "$f";;
            *) if [ -d "$f" ]; then ${pkgs.fd}/bin/fd "$f" -Htf -x "$0"; fi;;
          esac done &>/dev/null
        '';
      });
}
