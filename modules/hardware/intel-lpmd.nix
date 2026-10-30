# Intel Low Power Mode Daemon (paquet maison : absent de nixpkgs).
{ pkgs, ... }:

let
  lpmd = pkgs.callPackage ../../pkgs/intel-lpmd.nix { };
in
{
  environment.systemPackages = [ lpmd ];
  services.dbus.packages = [ lpmd ];
  systemd.packages = [ lpmd ];
  systemd.services.intel_lpmd.wantedBy = [ "multi-user.target" ];
}
