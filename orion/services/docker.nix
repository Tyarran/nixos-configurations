{ pkgs, ... }:

{
  imports = [ ./docker/immich.nix ];

  environment.systemPackages = with pkgs; [
    docker-compose
    arion
  ];

  virtualisation = {
    containers.enable = true;
    docker = {
      enable = true;
    };
  };
}
