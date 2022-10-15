flakes:
{ config, lib, ... }: {
  nix = {
    registry = builtins.mapAttrs (_: v: { flake = v; }) flakes;
    nixPath =
      lib.mapAttrsToList (k: v: "${k}=${v.to.path}") config.nix.registry;
  };
}

