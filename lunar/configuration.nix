# Dell XPS 13 (Lunar Lake) : poste de travail.
{
  pkgs,
  flakeRoot,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./users.nix
    ./packages.nix
    ./flatpak.nix
    ../modules/base.nix
    ../modules/locale.nix
    ../modules/workstation.nix
    ../modules/nordvpn.nix
    ../modules/desktop
    ../modules/desktop/gnome.nix
    ../modules/desktop/hyprland.nix
    ../modules/hardware/power-profiles.nix
    ../modules/hardware/nvme.nix
    ../modules/hardware/intel-lpmd.nix
    ../modules/hardware/scx-power.nix
    ../modules/hardware/btrfs-balance.nix
    ../modules/dev/neovim.nix
    ../modules/dev/containers.nix
    ../modules/compliance
  ];

  networking.hostName = "lunar";

  # Secrets (comme nova : clé age dans ~/.age/age.key, conservée avec @home)
  age.secrets.romain-password.file = "${flakeRoot}/secrets/lunar-romain-password.age";
  age.identityPaths = [ "/home/romain/.age/age.key" ];

  # Bootloader (ESP de 300 Mo partagée avec l'Arch pendant la transition)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel récent (Lunar Lake, driver xe, sched_ext pour scx)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Swap : zram seul (zswap désactivé pour éviter la double compression)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  boot.kernelParams = [
    "zswap.enabled=0"
    "intel_iommu=igfx_off"
    "xe.enable_fbc=1"
    "xe.enable_psr=1"
    "xe.enable_dc=4"
  ];

  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    # VM / mémoire (zram : pas de readahead sur le swap)
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
    "vm.compaction_proactiveness" = 20;
    "vm.laptop_mode" = 5;
    # Réseau
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_fin_timeout" = 30;
    # Sécurité
    "kernel.kptr_restrict" = 1;
    "fs.suid_dumpable" = 0;
    # Watchdog NMI désactivé (économie batterie)
    "kernel.nmi_watchdog" = 0;
    # Outils de dev (file watchers)
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 1024;
  };

  # /tmp nettoyé au boot
  boot.tmp.cleanOnBoot = true;

  # stateVersion identique au brouillon d'installation (flake en nixos-26.05 :
  # à surveiller au premier build)
  system.stateVersion = "26.11";
}
