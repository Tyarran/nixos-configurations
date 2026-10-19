{ ... }:

{
  imports = [
    ./openssh.nix
    ./cockpit.nix
    ./samba.nix
    ./dnsmasq.nix
    ./docker.nix
    ./docker/home-assistant.nix
    ./docker/deconz.nix
    ./backup.nix
  ];
}
