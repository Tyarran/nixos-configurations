# Paquets système : CLI et développement (les applis graphiques sont en flatpak).
{ pkgs, ... }:

{
  # Binaires précompilés (agents de conformité) : bibliothèques de base pour nix-ld
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc.lib ];

  environment.systemPackages =
    (with pkgs; [
      # --- Système ---
      btop
      htop
      powertop
      lm_sensors
      usbutils
      lsof
      smartmontools
      fio
      stress-ng
      gdb
      plocate
      ncdu
      tree
      wget
      unzip
      dfc
      intel-gpu-tools
      nvtopPackages.intel
      libva-utils
      vulkan-tools
      btrfs-progs
      age
      ssh-to-age

      # --- Shell / CLI ---
      zsh
      bat
      eza
      fd
      ripgrep
      fzf
      zoxide
      starship
      tmux
      tmuxp
      zellij
      yazi
      glow
      fastfetch
      tldr
      direnv
      keychain
      chezmoi
      mise
      yt-dlp
      pandoc
      wl-clipboard
      cliphist

      # --- Git / VCS ---
      git
      git-lfs
      gh
      jujutsu
      jjui
      lazygit
      lazyjj
      tig

      # --- Développement ---
      pgcli
      dbeaver-bin
      awscli2
      ngrok
      mkcert
      stripe-cli
      circleci-cli
      heroku
      insomnia
      vscode
      python3
      nodejs_24
      deno
      cargo
      rustc
      gcc
      gnumake
      cmake
      llvm
      ccache
      pyright
      vtsls
      eslint
      nixfmt
      statix
      deadnix
      claude-code
      opencode
      rtk
    ])
    ++ [
      # pi.dev : récent, depuis unstable
      pkgs.unstable.pi-coding-agent
    ];
}
