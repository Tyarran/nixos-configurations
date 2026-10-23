{ ... }:

{
  # Thermald - thermal management for Intel CPUs
  services.thermald.enable = true;

  # power-profiles-daemon - integrates with the GNOME profile switcher
  services.power-profiles-daemon.enable = true;
  services.tuned.enable = false;
}
