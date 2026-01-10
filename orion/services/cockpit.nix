{
  config,
  lib,
  pkgs,
  ...
}:

{

  environment.systemPackages = with pkgs; [
    sscg
    cockpit
  ];

  security.pam.services.cockpit = { };

  # systemd.services.cockpit = {
  #   environment.PATH = lib.mkForce
  #     "${pkgs.cockpit}/libexec:${pkgs.coreutils}/bin:${pkgs.openssh}/bin:${pkgs.sudo}/bin";
  #
  # };

  networking.firewall.allowedTCPPorts = [
    9090
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  services.cockpit = {
    enable = true;
    settings = {
      WebService = {
        AllowUnencrypted = true;
        # Environment =
        #   "PATH=${pkgs.cockpit}/libexec:${pkgs.coreutils}/bin:${pkgs.openssh}/bin:${pkgs.sudo}/bin";
      };
      Log = {
        Fatal = "warnings";
      };
    };

    allowed-origins = [
      "https://orion:9090"
      "https://192.168.1.200"
    ];
  };

}
