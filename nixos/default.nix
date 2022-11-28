flakes:
let
  inherit (builtins) readDir mapAttrs;
  inherit (flakes.nixpkgs.lib) pipe nixosSystem filterAttrs;
  mkSystem = hostname: cfg: cfg // {
    specialArgs = { inherit flakes hostname; };
    modules = cfg.modules ++ [
      flakes.impermanence.nixosModules.impermanence
      flakes.home-manager.nixosModules.home-manager
      ./common
    ];
  };
in
pipe (readDir ./.) [
  (filterAttrs (k: v: (v == "directory") && (k != "common")))
  (mapAttrs (k: _: nixosSystem (import (./. + "/${k}") flakes (mkSystem k))))
]
