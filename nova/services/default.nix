{ ... }:

{
  imports = [
    ./cosmic.nix
    ./gnome.nix
    ./yubikey.nix
    ./pipewire.nix
    ./flatpak.nix
    ./power-management.nix
    ./wireguard.nix
    ./gpu.nix
    ./io-scheduler.nix
  ];
}
