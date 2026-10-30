{ config, pkgs, ... }:

{
  programs.zsh.enable = true;

  users.users.romain = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Romain";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "nordvpn"
      "video"
      "render"
    ];
    hashedPasswordFile = config.age.secrets.romain-password.path;
  };
}
