# scx_cosmos (sched_ext) avec profil selon la source d'alimentation :
# secteur -> performance, batterie -> powersave. Une règle udev relance le service.
# Nécessite un kernel avec sched_ext (linuxPackages_latest).
{ pkgs, ... }:

let
  profile = pkgs.writeShellScript "scx-cosmos-profile" ''
    ac=0
    for f in /sys/class/power_supply/*; do
      if [ "$(cat "$f/type" 2>/dev/null)" = "Mains" ] && [ "$(cat "$f/online" 2>/dev/null)" = "1" ]; then
        ac=1
      fi
    done
    if [ "$ac" = "1" ]; then
      # Secteur : performance (P-cores, deadline permanent, tranches courtes)
      echo "SCX_ARGS=-m performance -P" > /run/scx-cosmos.env
    else
      # Batterie : économie (LPE, tâches collantes, tranches longues)
      echo "SCX_ARGS=-m powersave -P" > /run/scx-cosmos.env
    fi
  '';
in
{
  systemd.services.scx-cosmos = {
    description = "sched_ext scx_cosmos scheduler (profil AC/batterie)";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${profile}";
      EnvironmentFile = "-/run/scx-cosmos.env";
      ExecStart = "${pkgs.runtimeShell} -c 'exec ${pkgs.scx.full}/bin/scx_cosmos $SCX_ARGS'";
      Restart = "on-failure";
      RestartSec = 2;
      KillSignal = "SIGINT";
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl --no-block restart scx-cosmos.service"
  '';
}
