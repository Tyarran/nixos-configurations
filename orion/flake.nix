{
  description = "NixOS configuration for orion";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      agenix,
      arion,
      ...
    }:
    {
      nixosConfigurations.orion = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./configuration.nix
          agenix.nixosModules.default
          arion.nixosModules.arion
        ];
        specialArgs = { inherit agenix; };
      };
    };
}
