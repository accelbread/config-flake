flakes: pkgsFor:
let
  inherit (builtins) readDir mapAttrs;
  inherit (flakes.nixpkgs) lib;
  mkSystem = hostname: cfg:
    cfg // {
      pkgs = pkgsFor cfg.system;
      specialArgs = { inherit flakes hostname; };
      modules = cfg.modules ++ [
        flakes.impermanence.nixosModules.impermanence
        flakes.home-manager.nixosModules.home-manager
        ./common
      ];
    };
in mapAttrs (k: _: lib.nixosSystem (import (./. + "/${k}") flakes (mkSystem k)))
(lib.attrsets.filterAttrs (k: v: (v == "directory") && (k != "common"))
  (readDir ./.))
