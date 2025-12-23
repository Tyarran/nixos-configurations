# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./services
  ];

  age.secrets.romain-password = {
    file = ../secrets/orion-romain-password.age;
  };

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "orion";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 53 9090 443 139 445 ];
  networking.firewall.allowedUDPPorts = [ 53 443 137 138 ];

  time.timeZone = "Europe/Paris";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    neovim
    wget
    cockpit
    htop
    btop
    podman-compose
    ragenix
  ];

  system.stateVersion = "25.11";

}
