{
  outputs = { self, nixpkgs, flakelite }@inputs:
    flakelite.lib.mkFlake ./. {
      inherit inputs;
      devTools = pkgs: with pkgs; [ ];
    };
}
