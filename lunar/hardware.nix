# Spécificités matérielles du Dell XPS 13 9345 (Intel Core Ultra 7 256V, Lunar Lake).
{ pkgs, ... }:

{
  # --- Graphique : driver xe, Mesa récent (unstable) pour Arc 140V ---
  hardware.graphics = {
    enable = true;
    package = pkgs.unstable.mesa;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # --- Firmware, Bluetooth, réseau ---
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.sof-firmware ];
  hardware.bluetooth.enable = true;

  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=1
  '';

  # --- Énergie ---
  services.thermald.ignoreCpuidCheck = true;
  services.upower.enable = true; # requis par intel_lpmd

  # Évite les conflits thermiques ACPI (blacklist de l'Arch)
  boot.blacklistedKernelModules = [
    "int3400_thermal"
    "int3403_thermal"
    "acpi_thermal_rel"
  ];

  # XPS 13 9345 : tempête d'IRQ ACPI sur GPE6E
  systemd.services.disable-gpe6e = {
    description = "Disable ACPI GPE6E to prevent IRQ storm on XPS 13";
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "/sys/firmware/acpi/interrupts/gpe6E";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.runtimeShell} -c 'echo disable > /sys/firmware/acpi/interrupts/gpe6E'";
    };
  };

  # Affinité de l'IRQ I2C (le numéro 29 vient de l'Arch : peut changer, d'où la condition)
  systemd.services.irq-i2c-affinity = {
    description = "IRQ I2C Affinity Configuration";
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "/proc/irq/29";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.runtimeShell} -c 'echo 0-3,5-7 > /proc/irq/29/smp_affinity_list'";
    };
  };

  # --- Empreinte digitale : sudo, GDM, hyprlock ---
  services.fprintd.enable = true;
  security.pam.services = {
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
  };
}
