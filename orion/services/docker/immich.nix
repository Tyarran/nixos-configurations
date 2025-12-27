{ config, pkgs, ... }:

{
  # Configuration Arion pour Immich
  virtualisation.arion = {
    backend = "docker";

    projects.immich.settings = {
      services = {

        # === Immich Server ===
        immich-server.service = {
          image = "ghcr.io/immich-app/immich-server:release";
          container_name = "immich_server";

          ports = [ "8084:2283" ];

          volumes = [
            "/srv/storage/containers_data/Immich/library:/data"
            "/etc/localtime:/etc/localtime:ro"
          ];

          environment = {
            DB_HOSTNAME = "database";
            DB_USERNAME = "immich";
            DB_DATABASE_NAME = "immich";
            DB_PASSWORD = "$DB_PASSWORD";
            REDIS_HOSTNAME = "redis";
            UPLOAD_LOCATION = "./library";
          };

          depends_on = [ "redis" "database" ];
          restart = "always";
        };

        # === Immich Machine Learning (ARM optimized) ===
        immich-machine-learning.service = {
          # ARM Neural Network optimized image for Raspberry Pi 4
          image = "ghcr.io/immich-app/immich-machine-learning:release-armnn";
          container_name = "immich_machine_learning";

          volumes = [ "model-cache:/cache" ];

          environment = {
            DB_HOSTNAME = "database";
            DB_USERNAME = "postgres";
            DB_DATABASE_NAME = "immich";
            DB_PASSWORD = "$DB_PASSWORD";
            REDIS_HOSTNAME = "redis";
          };

          restart = "always";
        };

        # === Redis ===
        redis.service = {
          image =
            "docker.io/redis:6.2-alpine@sha256:905c4ee67b8e0aa955331960d2aa745781e6bd89afc44a8584bfd13bc890f0ae";
          container_name = "immich_redis";

          healthcheck = { test = [ "CMD-SHELL" "redis-cli ping || exit 1" ]; };

          restart = "always";
        };

        # === PostgreSQL with pgvecto.rs ===
        database.service = {
          image =
            "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
          container_name = "immich_postgres";

          environment = {
            POSTGRES_PASSWORD = "$DB_PASSWORD";
            POSTGRES_USER = "postgres";
            POSTGRES_DB = "immich";
            POSTGRES_INITDB_ARGS = "--data-checksums";
          };

          volumes = [
            "/srv/storage/containers_data/Immich/postgres:/var/lib/postgresql/data"
          ];

          command = [
            "postgres"
            "-c"
            "shared_preload_libraries=vectors.so"
            "-c"
            ''search_path="$$user", public, vectors''
            "-c"
            "logging_collector=on"
            "-c"
            "max_wal_size=1GB"
            "-c"
            "shared_buffers=256MB"
            "-c"
            "wal_compression=on"
          ];

          healthcheck = {
            test = [
              "CMD-SHELL"
              ''
                pg_isready --dbname="$POSTGRES_DB" --username="$POSTGRES_USER" || exit 1''
            ];
            interval = "5m";
            start_period = "5m";
          };

          restart = "always";
        };
      };

      # Volumes nommés
      docker-compose.volumes = { model-cache = { }; };
    };
  };

  # Injecter le secret via EnvironmentFile dans le service systemd
  systemd.services.arion-immich = {
    serviceConfig = {
      EnvironmentFile = config.age.secrets.orion-immich-db-password.path;
    };
  };

  # Création automatique des répertoires
  systemd.tmpfiles.rules = [
    "d /srv/storage/containers_data/Immich 0755 root root -"
    "d /srv/storage/containers_data/Immich/uploads 0755 root root -"
    "d /srv/storage/containers_data/Immich/postgres 0755 root root -"
    "d /srv/storage/containers_data/Immich/imports 0755 root root -"
  ];

  # Firewall - Ouvrir le port 8084 pour Immich
  networking.firewall.allowedTCPPorts = [ 8084 ];

  # Configuration du secret agenix
  age.secrets.orion-immich-db-password = {
    file = ../../../secrets/orion-immich-db-password.age;
    mode = "0400";
    owner = "root";
  };
}
