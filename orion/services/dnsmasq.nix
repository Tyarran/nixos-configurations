{ ... }:

{
  services.dnsmasq = {
    enable = true;
    settings = {
      no-resolv = true;
      server = [ "1.1.1.1" "1.1.0.0" "8.8.8.8" ];
      cache-size = 1000;
      log-queries = true;
      log-facility = "/var/log/dnsmasq.log";
    };
  };
}
