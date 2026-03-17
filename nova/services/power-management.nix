{ ... }:

{
  # Thermald - thermal management for Intel CPUs
  services.thermald.enable = true;

  # Tuned - system tuning service
  services.tuned.enable = true;
  services.tuned.ppdSettings = {
    profiles = {
      balanced = "balanced";
      performance = "throughput-performance";
      power-saver = "powersave";
    };
    battery = {
      balanced = "balanced-battery";
    };
  };

  powerManagement.cpuFreqGovernor = "powersave";

  # Set CPU Energy Performance Preference to balance_power for better efficiency
  systemd.services.set-cpu-epp = {
    description = "Set CPU energy performance preference to balance_power";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        if [ -f "$policy/energy_performance_preference" ]; then
          echo balance_power > "$policy/energy_performance_preference"
        fi
      done
    '';
  };

  # IrqBalance - distribute hardware interrupts across CPUs
  services.irqbalance.enable = true;
}
