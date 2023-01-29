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
          "cp --no-preserve=mode -r ${./.} src; cd src; ${cmd}; touch $out";
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
            mkdir -p $out
            zig build -Drelease-safe -Dcpu=baseline --prefix $out
          '';
          meta = with lib; {
            description = "Template Zig application.";
            license = licenses.agpl3Plus;
            platforms = platforms.linux;
          };
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues checks;
          packages = [ pkgs.zls ];
        };
        checks = {
          package = packages.default;
          test = runCheck
            "HOME=$TMPDIR ${lib.getExe pkgs.zig} build test";
          formatting = runCheck
            "HOME=$TMPDIR ${lib.getExe formatter} --fail-on-change";
        };
        formatter = pkgs.writeScriptBin "treefmt" ''
          PATH=${lib.makeBinPath (with pkgs; [
            treefmt
            zig
            nixpkgs-fmt
            nodePackages.prettier
          ])}
          exec treefmt "$@"
        '';
      });
}
