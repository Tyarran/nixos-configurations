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
    battery = { balanced = "balanced-battery"; };
  };

  # IrqBalance - distribute hardware interrupts across CPUs
  # services.irqbalance.enable = true;
}
