# Agents de conformité obligatoires sur la machine de travail.
{ ... }:

{
  imports = [
    ./sentinelone.nix
    ./vanta.nix
    ./clamav.nix
  ];
}
