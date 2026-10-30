# Réglages communs aux postes de travail (pas aux serveurs).
{
  pkgs,
  nixpkgs-unstable,
  ...
}:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Stable par défaut, `pkgs.unstable.<paquet>` au cas par cas
  nixpkgs.overlays = [
    (_final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];

  # Programmes non empaquetés (binaires précompilés)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  services.fwupd.enable = true;
  services.fwupd.daemonSettings.IdleTimeout = 86400;

  # Disable NetworkManager wait-online to speed up boot
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable fstrim for SSD optimization
  services.fstrim.enable = true;
  services.fstrim.interval = "weekly";

  # Enable systemd-oomd for better memory management
  systemd.oomd.enable = true;
  systemd.oomd.enableRootSlice = true;
  systemd.oomd.enableUserSlices = true;
}
