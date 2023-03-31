# hello-world -- Template Zig application
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
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls = {
      url = "github:zigtools/zls";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        zig-overlay.follows = "zig-overlay";
      };
    };
  };
  outputs = { self, nixpkgs, zig-overlay, zls }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      eachSystem = with nixpkgs.lib; f: foldAttrs mergeAttrs { }
        (map (s: mapAttrs (_: v: { ${s} = v; }) (f s)) systems);
    in
    eachSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              zig = zig-overlay.packages.${system}.master;
              zls = zls.packages.${system}.default;
            })
          ];
        };
        inherit (pkgs) lib;
        runCheck = cmd: pkgs.runCommand "check" { }
          "cp --no-preserve=mode -r ${./.} src; cd src\n${cmd}\ntouch $out";
        formatters = with pkgs; [ zig nixpkgs-fmt nodePackages.prettier ];
      in
      rec {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "hello-world";
          src = ./.;
          nativeBuildInputs = with pkgs; [ zig ];
          dontConfigure = true;
          dontInstall = true;
          XDG_CACHE_HOME = ".cache";
          buildPhase = ''
            runHook preBuild
            mkdir -p $out
            zig build -Doptimize=ReleaseSafe -Dcpu=baseline --prefix $out
            runHook postBuild
          '';
          meta = with lib; {
            description = "Template Zig application.";
            license = licenses.agpl3Plus;
            platforms = platforms.linux;
          };
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ packages.default ];
          packages = [ pkgs.zls ] ++ formatters;
        };
        checks = {
          package = packages.default;
          test = runCheck
            "HOME=$TMPDIR ${lib.getExe pkgs.zig} build test";
          formatting = runCheck ''
            ${lib.getExe formatter} .
            ${pkgs.diffutils}/bin/diff -qr ${./.} . |\
              sed 's/Files .* and \(.*\) differ/File \1 not formatted/g'
          '';
        };
        formatter = pkgs.writeShellScriptBin "formatter" ''
          PATH=${lib.makeBinPath formatters}
          for f in "$@"; do case "$f" in
            *.zig) zig fmt "$f";;
            *.nix) nixpkgs-fmt "$f";;
            *.md) prettier --write "$f";;
            *) if [ -d "$f" ]; then ${pkgs.fd}/bin/fd "$f" -Htf -x "$0"; fi;;
          esac done &>/dev/null
        '';
      });
}
