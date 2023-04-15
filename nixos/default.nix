{ inputs, ... }:
let
  inherit (builtins) readDir mapAttrs;
  inherit (inputs.nixpkgs.lib) pipe nixosSystem filterAttrs;
  mkSystem = hostname: cfg: cfg // {
    specialArgs = { inherit inputs hostname; };
    modules = cfg.modules ++ [
      inputs.impermanence.nixosModules.impermanence
      inputs.home-manager.nixosModules.home-manager
      ./common
    ];
  };
in
pipe (readDir ./.) [
  (filterAttrs (k: v: (v == "directory") && (k != "common")))
  (mapAttrs (k: _: nixosSystem (import (./. + "/${k}") inputs (mkSystem k))))
]
