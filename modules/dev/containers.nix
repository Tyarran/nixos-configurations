# Docker, Podman et Ollama.
{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = [
        "8.8.8.8"
        "1.1.1.1"
      ];
      live-restore = false;
    };
  };
  virtualisation.podman.enable = true;

  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    environmentVariables.OLLAMA_IGPU_ENABLE = "1";
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
    lazydocker
  ];
}
