# Template Rust application
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
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs = { self, nixpkgs, crane, treefmt-nix }:
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
        craneLib = crane.lib.${system};
        cargoArtifacts = craneLib.buildDepsOnly { inherit src; };
        fmtCfg = {
          projectRootFile = "flake.nix";
          programs = {
            rustfmt = { enable = true; inherit (cargoToml.package) edition; };
            nixpkgs-fmt.enable = true;
            prettier.enable = true;
          };
        };
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
          packages = with pkgs; [ rust-analyzer ];
        };
        checks = {
          package = packages.default;
          clippy = craneLib.cargoClippy {
            inherit src cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          };
          formatting =
            (treefmt-nix.lib.evalModule pkgs fmtCfg).config.build.check self;
        };
        formatter = treefmt-nix.lib.mkWrapper pkgs fmtCfg;
      });
}
