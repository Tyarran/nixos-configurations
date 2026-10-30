# Antivirus ClamAV (daemon + mise à jour des signatures).
{ ... }:

{
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };
}
