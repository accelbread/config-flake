# hello-world -- Template Rust application
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
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, crane }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      eachSystem = with nixpkgs.lib; f: foldAttrs mergeAttrs { }
        (map (s: mapAttrs (_: v: { ${s} = v; }) (f s)) systems);
      src = ./.;
      cargoToml = builtins.fromTOML (builtins.readFile (src + "/Cargo.toml"));
    in
    eachSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;
        craneLib = crane.lib.${system};
        cargoArtifacts = craneLib.buildDepsOnly { inherit src; };
        runCheck = cmd: pkgs.runCommand "check" { }
          "cp --no-preserve=mode -r ${./.} src; cd src; ${cmd}; touch $out";
        formatters = with pkgs; [
          treefmt
          rustfmt
          nixpkgs-fmt
          nodePackages.prettier
        ];
      in
      rec {
        packages.default = craneLib.buildPackage {
          inherit src cargoArtifacts;
          meta = with pkgs.lib; {
            description = cargoToml.package.description;
            license = licenses.agpl3Plus;
            platforms = platforms.linux;
          };
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues checks;
          packages = with pkgs; [ rust-analyzer rustc ] ++ formatters;
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
        checks = {
          package = packages.default;
          clippy = craneLib.cargoClippy {
            inherit src cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          };
          formatting = runCheck
            "HOME=$TMPDIR ${lib.getExe formatter} --fail-on-change";
        };
        formatter = pkgs.writeScriptBin "treefmt" ''
          PATH=${lib.makeBinPath formatters}
          exec treefmt "$@"
        '';
      });
}
