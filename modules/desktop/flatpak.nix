# Flatpak déclaratif via nix-flatpak (le module est ajouté dans flake.nix).
# Les applis à installer se déclarent par hôte : services.flatpak.packages = [ ... ];
{ ... }:

{
  services.flatpak = {
    enable = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
