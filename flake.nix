{
  description = "NixOS configurations for all hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      agenix,
      arion,
      nix-flatpak,
      ...
    }:
    {
      nixosConfigurations = {
        # Nova configuration (x86_64-linux)
        nova = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nova/configuration.nix
            agenix.nixosModules.default
            nix-flatpak.nixosModules.nix-flatpak
          ];
          specialArgs = {
            inherit agenix nixpkgs-unstable;
            flakeRoot = ./.;
          };
        };

        # Lunar configuration : poste de travail Dell XPS 13 (x86_64-linux)
        lunar = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./lunar/configuration.nix
            agenix.nixosModules.default
            nix-flatpak.nixosModules.nix-flatpak
          ];
          specialArgs = {
            inherit agenix nixpkgs-unstable;
            flakeRoot = ./.;
          };
        };

        # Orion configuration (aarch64-linux)
        orion = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./orion/configuration.nix
            agenix.nixosModules.default
            arion.nixosModules.arion
          ];
          specialArgs = {
            inherit agenix;
            flakeRoot = ./.;
          };
        };
      };
    };
}
