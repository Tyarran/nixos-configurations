{ pkgs, ... }:

{
  # Intel GPU (UHD 620 - Whiskey Lake) configuration
  # PCI ID: 8086:3EA0

  # Enable graphics hardware acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For 32-bit applications

    # Intel-specific drivers
    extraPackages = with pkgs; [
      intel-media-driver # iHD VA-API driver (modern, recommended for Gen 8+)
      intel-compute-runtime-legacy1 # OpenCL support (Gen8-11)
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      intel-media-driver
    ];
  };

  # Environment variables for GPU acceleration
  environment.sessionVariables = {
    # VA-API: Use iHD driver (intel-media-driver) for Whiskey Lake
    LIBVA_DRIVER_NAME = "iHD";

    # Enable hardware video acceleration in browsers
    MOZ_ENABLE_WAYLAND = "1"; # Firefox Wayland support
  };

  # Additional i915 kernel parameters for optimal GPU performance
  # Already configured in configuration.nix:
  # - i915.enable_psr=1 (Panel Self Refresh - save power)
  # - i915.enable_psr2_sel_fetch=1 (PSR2 selective fetch - more efficient)
  # - i915.enable_fbc=1 (Framebuffer compression - save bandwidth)
  # - i915.enable_dc=2 (Display C-states - deeper power saving)
  # - i915.enable_guc=2 (GuC firmware for submission + HuC)
}
