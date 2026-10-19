{ config, pkgs, ... }:

{
  virtualisation.arion.projects.deconz.settings = {
    services.deconz.service = {
      image = "deconzcommunity/deconz:stable";
      container_name = "deconz";
      restart = "unless-stopped";
      privileged = true;

      ports = [
        "8080:80"
        "8443:443"
      ];

      volumes = [
        "/srv/storage/containers_data/deconz:/opt/deCONZ"
        "/etc/localtime:/etc/localtime:ro"
      ];

      devices = [
        "/dev/serial0:/dev/ttyAMA0"
      ];

      environment = {
        TZ = "Europe/Paris";
        DECONZ_DEVICE = "/dev/ttyAMA0";
        DECONZ_BAUDRATE = "38400";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/storage/containers_data/deconz 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [
    8080
    8443
  ];

  hardware.bluetooth.enable = false;
}
