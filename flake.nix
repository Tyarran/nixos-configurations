{
  description = "NixOS configuration with ragenix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ragenix, ... }: {
    nixosConfigurations = {
      orion = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./orion/configuration.nix
          ragenix.nixosModules.default
        ];
      };
    };
  };
}
