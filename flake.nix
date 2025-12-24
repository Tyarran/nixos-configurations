{
  description = "NixOS configuration with agenix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, ... }: {
    nixosConfigurations = {
      orion = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ ./orion/configuration.nix agenix.nixosModules.default ];
        specialArgs = { inherit agenix; };
      };
      nova = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nova/configuration.nix agenix.nixosModules.default ];
        specialArgs = { inherit agenix; };
      };
    };
  };
}
