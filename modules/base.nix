# Socle minimal commun à tous les hôtes (poste de travail ou serveur).
{ lib, ... }:

{
  networking.networkmanager.enable = lib.mkDefault true;
  time.timeZone = lib.mkDefault "Europe/Paris";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  nix.optimise.automatic = lib.mkDefault true;
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    persistent = lib.mkDefault false; # évite un long GC de rattrapage au boot
    options = lib.mkDefault "--delete-older-than 14d";
  };
}
