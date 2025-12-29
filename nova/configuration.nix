# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, agenix, ... }:

let
  # Import du module cockpit-nix depuis GitHub
  cockpit-nix = import (fetchTarball
    "https://github.com/addreas/cockpit-nix/archive/main.tar.gz") {
      inherit pkgs;
    };
in {
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./locale.nix
    ./keyboard.nix
    ./services
  ];

  # Secrets management
  age.secrets.romain-password = { file = ../secrets/nova-romain-password.age; };
  age.identityPaths = [ "/home/romain/.age/age.key" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "nova";
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Europe/Paris";

  # Nix settings
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Enable ARM emulation for building Raspberry Pi configs
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Unstable overlay
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import (prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "nixos-unstable";
        sha256 = "sha256-QEhk0eXgyIqTpJ/ehZKg9IKS7EtlWxF3N7DXy42zPfU=";
      }) {
        system = prev.stdenv.hostPlatform.system;
        config = final.config;
      };
    })
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    wget
    unstable.neovim
    unstable.btop
    htop
    powertop
    thermald
    tuned
    dfc
    irqbalance
    intel-gpu-tools
    intel-vaapi-driver
    intel-media-driver
    intel-graphics-compiler
    tmux
    yubico-pam
    docker
    libgda6
    gsound
    nvtopPackages.intel
    lm_sensors
    cockpit
    lix
    kexec-tools
    libva-vdpau-driver
    wireguard-tools
    unzip
    solaar
    ssh-to-age
    agenix
    sops
    age
    ragenix
  ];

  # Services
  services.printing.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
