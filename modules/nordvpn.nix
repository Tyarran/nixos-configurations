# NordVPN : le module NixOS n'existe que dans nixpkgs-unstable, on l'importe d'ici
# avec le paquet unstable correspondant.
{ pkgs, nixpkgs-unstable, ... }:

{
  imports = [ "${nixpkgs-unstable}/nixos/modules/services/networking/nordvpn.nix" ];

  services.nordvpn = {
    enable = true;
    package = pkgs.unstable.nordvpn;
  };

  # Le manuel NixOS stable ne connaît pas la doc de ce module (identifiant
  # module-services-nordvpn absent des redirections) : sans cela, le build échoue.
  documentation.nixos.enable = false;

  # Requis par nordvpn quand le pare-feu est actif
  networking.firewall.checkReversePath = "loose";
}
