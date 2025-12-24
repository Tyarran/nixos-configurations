{ ... }:

{
  services.cockpit = {
    enable = true;
    #   packages = with pkgs; [
    #     # cockpit-podman sera automatiquement disponible via le module
    #   ];
  };
}
