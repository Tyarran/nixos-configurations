{ pkgs, lib, ... }:

{
  # Enable the X11 windowing system
  services.xserver.enable = false;

  # Enable the GNOME Desktop Environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Disable unused GNOME services for better performance
  services.gnome.evolution-data-server.enable = lib.mkForce false;
  services.gnome.gnome-online-accounts.enable = lib.mkForce false;

  # Remove unused GNOME packages to save RAM and disk space
  environment.gnome.excludePackages = with pkgs; [
    epiphany # GNOME Web browser
    geary # Email client
    gnome-tour
  ];

  # GNOME packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];
}
