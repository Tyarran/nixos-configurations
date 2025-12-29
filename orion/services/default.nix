{ ... }:

{
  imports = [
    ./openssh.nix
    ./cockpit.nix
    ./samba.nix
    ./dnsmasq.nix
    ./docker.nix
    ./backup.nix
  ];
}
