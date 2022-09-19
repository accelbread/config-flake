{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = { self, nixpkgs, nixos-hardware, home-manager, impermanence }: {
    nixosConfigurations.shadowfang = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.framework
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        {
          nix.registry.nixpkgs.flake = nixpkgs;
        }
        ./configuration.nix
      ];
    };
  };
}

