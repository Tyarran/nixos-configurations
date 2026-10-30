{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.neovim

    # Neovim dependencies
    deno
    tree-sitter
    luajitPackages.luarocks
    imagemagick
    ghostscript
    tectonic
    mermaid-cli
    fd
    lua5_1

    # Programming languages for neovim
    go
    ruby
    php
    julia
    zulu
    python3
    python313Packages.pip
    # php84Packages.composer
  ];
}
