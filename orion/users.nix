{ config, pkgs, ... }:

{
  users.groups.samba = { };

  users.users = {
    romain = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "podman"
        "samba"
      ];
      packages = with pkgs; [
        tree
        ncdu
        ddrescue
        dfc
        fzf
      ];
      hashedPasswordFile = config.age.secrets.orion-romain-password.path;
    };
  };
}
