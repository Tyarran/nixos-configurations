# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  agenix,
  flakeRoot,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./services
  ];

  age.secrets.orion-romain-password = {
    file = "${flakeRoot}/secrets/orion-romain-password.age";
  };

  age.identityPaths = [ "/etc/age/age.key" ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "orion";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.sandbox = false;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    htop
    btop
    agenix
    ssh-to-age
    tree
    rclone
  ];

  services.irqbalance.enable = true;
  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 30d";

  system.stateVersion = "25.11";

}
