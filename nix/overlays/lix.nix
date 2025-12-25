final: prev: {
  nix-direnv = prev.nix-direnv.override { nix = final.lix; };
}
