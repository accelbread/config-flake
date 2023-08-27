{
  inputs.flakelight.url = "github:accelbread/flakelight";
  outputs = { nixpkgs, flakelight, ... }@inputs:
    flakelight ./. {
      inherit inputs;
      devShell.packages = pkgs: with pkgs; [ ];
    };
}
