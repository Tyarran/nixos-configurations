# Vanta : binaires copiés dans /var/vanta (l'agent s'y met à jour lui-même),
# configuration d'enrôlement (/etc/vanta.conf) fournie par agenix.
{
  config,
  pkgs,
  flakeRoot,
  ...
}:

let
  vanta = pkgs.callPackage ../../pkgs/vanta.nix { };

  prep = pkgs.writeShellScript "vanta-prep" ''
    set -eu
    mkdir -p /var/vanta
    # Première installation seulement : ensuite l'agent gère ses propres mises à jour
    if [ ! -e /var/vanta/metalauncher ]; then
      cp -rn --no-preserve=ownership ${vanta}/var/vanta/. /var/vanta/
      chmod -R u+rwX,go+rX /var/vanta
    fi
    if [ ! -e /etc/vanta.conf ]; then
      install -m 0600 ${config.age.secrets.vanta-conf.path} /etc/vanta.conf
    fi
  '';
in
{
  age.secrets.vanta-conf.file = "${flakeRoot}/secrets/lunar-vanta-conf.age";

  # osqueryd est dynamique (glibc seulement) ; metalauncher est statique.
  programs.nix-ld.libraries = [ pkgs.stdenv.cc.cc.lib ];

  environment.systemPackages = [ vanta ];

  systemd.services.vanta-agent = {
    description = "Vanta monitoring software";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [
      coreutils
      util-linux
    ];
    serviceConfig = {
      TimeoutStartSec = 0;
      ExecStartPre = "+${prep}";
      ExecStart = "/var/vanta/metalauncher";
      KillMode = "control-group";
      KillSignal = "SIGTERM";
      # L'agent se fige régulièrement : redémarrage forcé toutes les 12 h (comme sur Arch)
      Restart = "always";
      RuntimeMaxSec = "12h";
    };
  };
}
