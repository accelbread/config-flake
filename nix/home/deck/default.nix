{ inputs, ... }: {
  system = "x86_64-linux";
  modules = [
    ./home.nix
    { home.stateVersion = "23.11"; }
    inputs.self.homeModules.standalone
  ];
}
