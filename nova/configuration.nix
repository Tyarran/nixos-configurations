# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  config,
  pkgs,
  lib,
  agenix,
  flakeRoot,
  nixpkgs-unstable,
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
    file = "${flakeRoot}/secrets/nova-romain-password.age";
  };
  age.identityPaths = [ "/home/romain/.age/age.key" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = lib.mkAfter [
    # Intel i915 GPU optimizations
    "i915.enable_psr=1" # Panel Self Refresh - reduces power
    "i915.enable_fbc=1" # Framebuffer compression - saves bandwidth
    "i915.fastboot=1" # Faster boot by reusing GOP/UEFI framebuffer
  ];

  # Kernel sysctl tuning for desktop performance
  boot.kernel.sysctl = {
    # === Scheduler ===
    # Enable scheduler autogroup for better desktop responsiveness
    "kernel.sched_autogroup_enabled" = 1;

    # === Memory Management ===
    # Reduce dirty page ratios for better responsiveness on SSD
    "vm.dirty_ratio" = 10; # Start blocking writes at 10% RAM (down from 20%)
    "vm.dirty_background_ratio" = 5; # Start background writes at 5% RAM (down from 10%)
    # Kernel defaults, suited to NVMe
    "vm.dirty_writeback_centisecs" = 500; # Write every 5s
    "vm.dirty_expire_centisecs" = 3000; # Expire after 30s

    # === Network Performance ===
    "net.core.default_qdisc" = "fq"; # Recommended qdisc for BBR
    "net.ipv4.tcp_congestion_control" = "bbr"; # Google BBR for better throughput
    "net.ipv4.tcp_fastopen" = 3; # Enable TFO for client and server
    "net.core.netdev_max_backlog" = 16384; # Increase network queue (from 1000)
    "net.ipv4.tcp_slow_start_after_idle" = 0; # Disable slow start after idle

    # TCP window scaling for high-bandwidth connections
    "net.core.rmem_max" = 16777216; # 16MB max receive buffer
    "net.core.wmem_max" = 16777216; # 16MB max send buffer
    "net.ipv4.tcp_rmem" = "4096 87380 16777216"; # TCP read buffer min/default/max
    "net.ipv4.tcp_wmem" = "4096 65536 16777216"; # TCP write buffer min/default/max

    # === File System ===
    # Increase inotify limits for development (VS Code, file watchers, etc.)
    "fs.inotify.max_user_watches" = 1048576; # 1M watches (up from 524288)
    "fs.inotify.max_user_instances" = 1024; # 1024 instances (kernel default is 128)

    # === Kernel ===
    # Disable watchdogs to save CPU cycles (safe on desktop)
    "kernel.nmi_watchdog" = 0;
    "kernel.watchdog" = 0;
  };

  # Clean /tmp on boot (RAM is too small for tmpfs during Nix builds)
  boot.tmp.cleanOnBoot = true;

  # Networking
  networking.hostName = "nova";
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Europe/Paris";

  # Nix settings
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Remote builders for aarch64
  nix.buildMachines = [
    {
      hostName = "192.168.1.200";
      sshUser = "romain";
      sshKey = "/home/romain/.ssh/id_ed25519";
      system = "aarch64-linux";
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
      ];
    }
  ];
  nix.distributedBuilds = true;

  # Enable ARM emulation for building Raspberry Pi configs
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Overlays: disable solaar tests and add unstable packages
  nixpkgs.overlays = [
    # Disable solaar tests due to D-Bus machine-id requirement in build environment
    # (final: prev: {
    #   solaar = prev.solaar.overrideAttrs (old: {
    #     doCheck = false;
    #   });
    # })
    # Unstable packages overlay
    (final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
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
    dfc
    intel-gpu-tools
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
    wireguard-tools
    unzip
    # solaar
    # ssh-to-age
    agenix
    sops
    age
    ragenix
    libva-utils
    vulkan-tools
    jujutsu
  ];

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.persistent = false; # avoid a long catch-up GC at boot
  nix.gc.options = "--delete-older-than 14d";

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  # Services
  # services.printing.enable = false;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
