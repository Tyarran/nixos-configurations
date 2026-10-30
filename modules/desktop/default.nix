# Socle commun à tous les environnements de bureau.
# Chaque DE (gnome, hyprland...) est un module autonome à importer en plus.
{ ... }:

{
  imports = [
    ./pipewire.nix
    ./flatpak.nix
  ];
}
