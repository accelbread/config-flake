{
  inputs.flakelite.url = "github:accelbread/flakelite";
  outputs = { self, nixpkgs, flakelite }@inputs:
    flakelite ./. {
      inherit inputs;
      devTools = pkgs: with pkgs; [ ];
    };
}
