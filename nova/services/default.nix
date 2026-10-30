{ ... }:

{
  imports = [
    # ./cosmic.nix
    ../../modules/desktop
    ../../modules/desktop/gnome.nix
    ./yubikey.nix
    ../../modules/hardware/power-profiles.nix
    ./wireguard.nix
    ./gpu.nix
    ../../modules/hardware/nvme.nix
  ];
}
