{ inputs, ... }:
let
  inherit (builtins) readDir mapAttrs head match;
  inherit (inputs.nixpkgs.lib) pipe filterAttrs;

  mkHome = name: cfg: inputs.home-manager.lib.homeManagerConfiguration {
    extraSpecialArgs = { inherit inputs; };
    pkgs = inputs.nixpkgs.legacyPackages.${cfg.system};
    modules = cfg.modules or [ ] ++ [
      { home.username = head (match "([^@]*)(@.*)?" name); }
      { home = { inherit (cfg) stateVersion; }; }
      inputs.self.homeModules.standalone
    ];
  };
in
pipe (readDir ./.) [
  (filterAttrs (k: v: v == "directory"))
  (mapAttrs (k: _: mkHome k (import (./. + "/${k}"))))
]
