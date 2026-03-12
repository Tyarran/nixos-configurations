# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  config,
  pkgs,
  lib,
  agenix,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./locale.nix
    ./keyboard.nix
    ./services
    ./applications
  ];

  # Secrets management
  age.secrets.romain-password = {
    file = ../secrets/nova-romain-password.age;
  };
  age.identityPaths = [ "/home/romain/.age/age.key" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = lib.mkAfter [
    "i915.enable_psr=1"
    "i915.enable_psr2_sel_fetch=1"
    "i915.enable_fbc=1"
    "i915.enable_dc=2"
    "i915.enable_guc=2"
  ];

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
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Unstable overlay
  nixpkgs.overlays = [
    (final: prev: {
      unstable =
        import
          (prev.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "nixos-unstable";
            sha256 = "sha256-QEhk0eXgyIqTpJ/ehZKg9IKS7EtlWxF3N7DXy42zPfU=";
          })
          {
            system = prev.stdenv.hostPlatform.system;
            config = final.config;
          };
    })
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    wget
    btop
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
    lix
    kexec-tools
    libva-vdpau-driver
    wireguard-tools
    unzip
    solaar
    # ssh-to-age
    agenix
    sops
    age
    ragenix
    libva-utils
    jujutsu
  ];

  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 30d";

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  # Services
  # services.printing.enable = false;
  services.fwupd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
