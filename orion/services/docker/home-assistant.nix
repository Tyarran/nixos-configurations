{ config, pkgs, ... }:

let
  # Version de Home Assistant à déployer
  homeAssistantVersion = "2026.3.4"; # Mettre à jour cette version pour upgrader Home Assistant
in
{
  # Configuration Arion pour Home Assistant
  virtualisation.arion = {
    backend = "docker";

    projects.home-assistant.settings = {
      services = {

        # === Home Assistant ===
        homeassistant.service = {
          image = "ghcr.io/home-assistant/home-assistant:${homeAssistantVersion}";
          container_name = "homeassistant";

          # Mode réseau host pour découverte automatique des appareils
          network_mode = "host";

          volumes = [
            "/srv/storage/containers_data/HomeAssistant/config:/config"
            "/etc/localtime:/etc/localtime:ro"
            "/run/dbus:/run/dbus:ro" # Pour Bluetooth
          ];

          environment = {
            TZ = "Europe/Paris";
          };

          # Healthcheck pour vérifier que Home Assistant fonctionne
          healthcheck = {
            test = [
              "CMD"
              "curl"
              "-f"
              "http://localhost:8123"
            ];
            interval = "30s";
            timeout = "10s";
            retries = 3;
            start_period = "90s";
          };

          restart = "unless-stopped";
        };
      };

      # Configuration Docker Compose brute pour les capacités (non supporté directement par Arion)
      docker-compose.raw = {
        services.homeassistant = {
          cap_add = [
            "NET_ADMIN" # Requis pour la gestion des adaptateurs Bluetooth
            "NET_RAW" # Requis pour la récupération automatique des adaptateurs
          ];
        };
      };
    };
  };

  # Création automatique des répertoires
  systemd.tmpfiles.rules = [
    "d /srv/storage/containers_data/HomeAssistant 0755 root root -"
    "d /srv/storage/containers_data/HomeAssistant/config 0755 root root -"
  ];

  # Firewall - Ouvrir le port 8123 pour Home Assistant
  # Note: Avec network_mode: host, c'est nécessaire
  networking.firewall.allowedTCPPorts = [ 8123 ];

}
