{ ... }:

{
  imports = [
    ./openssh.nix
    ./cockpit.nix
    ./samba.nix
    ./dnsmasq.nix
    ./docker.nix
    ./docker/home-assistant.nix
    ./backup.nix
  ];
}
