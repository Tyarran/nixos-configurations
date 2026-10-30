# Dell XPS 13 9345 (Lunar Lake). UUID repris de l'Arch actuelle.
# La racine et /var sont de NOUVEAUX sous-volumes (@nixos, @nixos-var) ;
# @home est conservé tel quel. Pas de swap disque : zram seul (voir configuration.nix).
{
  config,
  lib,
  modulesPath,
  ...
}:

let
  btrfsOpts = [
    "compress=zstd:3"
    "noatime"
    "discard=async"
    "ssd"
  ];
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."cryptdev" = {
    device = "/dev/disk/by-uuid/e869860d-57e2-43cf-8249-c2c9bd0e2e7b";
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/cryptdev";
    fsType = "btrfs";
    options = [ "subvol=@nixos" ] ++ btrfsOpts;
  };

  fileSystems."/home" = {
    device = "/dev/mapper/cryptdev";
    fsType = "btrfs";
    options = [ "subvol=@home" ] ++ btrfsOpts;
    # La clé age (~/.age/age.key) doit être disponible dès l'activation (secrets agenix)
    neededForBoot = true;
  };

  fileSystems."/var" = {
    device = "/dev/mapper/cryptdev";
    fsType = "btrfs";
    options = [ "subvol=@nixos-var" ] ++ btrfsOpts;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FD42-BA17";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
