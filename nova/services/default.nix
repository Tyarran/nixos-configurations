{ ... }:

{
  imports = [
    ./cosmic.nix
    ./gnome.nix
    ./cockpit.nix
    ./yubikey.nix
    ./pipewire.nix
    ./flatpak.nix
    ./power-management.nix
    ./wireguard.nix
  ];
}
