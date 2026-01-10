{ pkgs, ... }:

{
  # Enable the X11 windowing system
  services.xserver.enable = false;

  # Enable the GNOME Desktop Environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GNOME packages
  environment.systemPackages = with pkgs; [
    gnome-software
    gnome-tweaks
  ];
}
