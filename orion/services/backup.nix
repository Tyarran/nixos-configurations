{ config, pkgs, ... }:

{
  # Secrets
  age.secrets = {
    orion-scaleway-access-key = {
      file = ../../secrets/orion-scaleway-access-key.age;
      mode = "0400";
      owner = "root";
    };

    orion-scaleway-secret-key = {
      file = ../../secrets/orion-scaleway-secret-key.age;
      mode = "0400";
      owner = "root";
    };

    orion-backup-password = {
      file = ../../secrets/orion-backup-password.age;
      mode = "0400";
      owner = "root";
    };
  };

  # Service systemd
  systemd.services.orion-backup = {
    description = "Sauvegarde chiffrée quotidienne Orion vers Scaleway Glacier";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      # Lecture des secrets
      ACCESS_KEY=$(cat ${config.age.secrets.orion-scaleway-access-key.path})
      SECRET_KEY=$(cat ${config.age.secrets.orion-scaleway-secret-key.path})
      CRYPT_PASS=$(cat ${config.age.secrets.orion-backup-password.path})

      # Configuration rclone
      export RCLONE_CONFIG_SCALEWAY_TYPE=s3
      export RCLONE_CONFIG_SCALEWAY_PROVIDER=Other
      export RCLONE_CONFIG_SCALEWAY_REGION=fr-par
      export RCLONE_CONFIG_SCALEWAY_ENDPOINT=https://s3.fr-par.scw.cloud
      export RCLONE_CONFIG_SCALEWAY_ACCESS_KEY_ID="$ACCESS_KEY"
      export RCLONE_CONFIG_SCALEWAY_SECRET_ACCESS_KEY="$SECRET_KEY"
      export RCLONE_CONFIG_SCALEWAY_STORAGE_CLASS=GLACIER

      export RCLONE_CONFIG_BACKUP_TYPE=crypt
      export RCLONE_CONFIG_BACKUP_REMOTE=scaleway:orion-backup-glacier
      export RCLONE_CONFIG_BACKUP_PASSWORD="$CRYPT_PASS"
      export RCLONE_CONFIG_BACKUP_PASSWORD2="$CRYPT_PASS"

      # Synchronisation chiffrée
      ${pkgs.rclone}/bin/rclone sync \
        --log-level=INFO \
        --log-file=/var/log/orion-backup.log \
        /srv/storage/containers_data/ \
        backup:
    '';
  };

  # Timer quotidien 02:00
  systemd.timers.orion-backup = {
    description = "Timer quotidien pour la sauvegarde chiffrée Orion";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "02:00";
      Persistent = true;
    };
  };

  # Répertoire de logs
  systemd.tmpfiles.rules = [ "d /var/log 0755 root root -" ];
}
