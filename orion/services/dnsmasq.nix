{ ... }:

{
  services.dnsmasq = {
    enable = true;
    settings = {
      no-resolv = true;
      server = [
        "1.1.1.1"
        "1.1.0.0"
        "8.8.8.8"
      ];
      cache-size = 1000;
      log-queries = true;
      log-facility = "/var/log/dnsmasq.log";
    };
  };

  networking.hosts = {
    "192.168.1.200" = [ "orion" ];
    "192.168.1.169" = [ "callisto" ];
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
