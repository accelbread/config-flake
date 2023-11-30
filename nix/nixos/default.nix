{ inputs, ... }:
let
  inherit (builtins) readDir mapAttrs;
  inherit (inputs.nixpkgs.lib) pipe nixosSystem filterAttrs;

  mkSystem = hostname: cfg: nixosSystem (cfg // {
    specialArgs = { inherit inputs hostname; };
    modules = cfg.modules ++ [ inputs.self.nixosModules.common ];
  });
in
pipe (readDir ./.) [
  (filterAttrs (k: v: v == "directory"))
  (mapAttrs (k: _: mkSystem k (import (./. + "/${k}"))))
]
