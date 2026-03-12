{ config, pkgs, ... }:

{
  # Programmes système accessibles aux utilisateurs
  programs.zsh.enable = true;
  programs.firefox.enable = false;

  users.users.romain = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Romain";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      zsh
      fzf
      ripgrep
      keychain
      mise
      eza
      bat
      opencode
      tmuxp
      ghostty
      cargo
      gcc
      gnumake
      chezmoi
      gh
      kitty
      elixir
      starship
      yazi
      git
      monaspace
      podman
      libva-utils
      nodejs_24
      nixfmt
      statix
      deadnix
    ];
    hashedPasswordFile = config.age.secrets.romain-password.path;
  };
}
