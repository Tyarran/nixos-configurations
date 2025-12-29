{
  description = "NixOS configuration with agenix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, agenix, arion, ... }: {
    nixosConfigurations = {
      orion = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./orion/configuration.nix
          agenix.nixosModules.default
          arion.nixosModules.arion
        ];
        specialArgs = { inherit agenix; };
      };
      nova = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nova/configuration.nix agenix.nixosModules.default ];
        specialArgs = { inherit agenix; };
      };
    };
  };
}
