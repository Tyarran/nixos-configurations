# Hyprland (famille hypr* depuis nixpkgs-unstable : la config Lua exige >= 0.56).
# Les dotfiles (hyprland.lua, waybar...) restent gérés par chezmoi.
{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = pkgs.unstable.hyprland;
    portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
  };

  # PAM pour hyprlock (l'empreinte s'ajoute dans l'hôte)
  programs.hyprlock = {
    enable = true;
    package = pkgs.unstable.hyprlock;
  };

  security.polkit.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages =
    (with pkgs.unstable; [
      hypridle
      hyprpicker
      hyprpolkitagent
      hyprshot
    ])
    ++ (with pkgs; [
      waybar
      swaynotificationcenter
      rofi
      rofimoji
      nwg-displays
      nwg-look
      kanshi
      brightnessctl
      networkmanagerapplet
      pasystray
      avizo
      awww
      playerctl
      wl-clipboard
      cliphist
      matugen
      waypaper
      quickshell
      ghostty
    ]);
}
