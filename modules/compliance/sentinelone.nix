# SentinelOne : installeur .deb (requireFile), exécuté depuis /opt/sentinelone (inscriptible),
# token d'enrôlement fourni par agenix.
{
  config,
  pkgs,
  flakeRoot,
  ...
}:

let
  s1 = pkgs.callPackage ../../pkgs/sentinelone.nix { };
  installDir = "/opt/sentinelone";
  ctl = "${installDir}/bin/sentinelctl";

  # Copie l'installeur dans /opt/sentinelone (équivalent du postinst du .deb).
  # Première installation : tout est copié. Mise à jour : l'état (configuration, logs...) est conservé.
  sync = pkgs.writeShellScript "sentinelone-sync" ''
    set -eu
    marker=${installDir}/.nix-version
    if [ "$(cat "$marker" 2>/dev/null || true)" = "${s1.version}" ]; then
      exit 0
    fi
    mkdir -p ${installDir}
    if [ -e "$marker" ]; then
      excludes="--exclude=/configuration/ --exclude=/log/ --exclude=/.storage/ --exclude=/crash_dumps/ --exclude=/uploads/ --exclude=/auto_uploads/ --exclude=/mount/ --exclude=/cgroups/ --exclude=/model/ --exclude=/tmp/"
    else
      excludes=""
    fi
    ${pkgs.rsync}/bin/rsync -a --no-owner --no-group --chmod=u+rwX $excludes ${s1}/opt/sentinelone/ ${installDir}/
    chown -R sentinelone:sentinelone ${installDir}
    chown -R root:sentinelone ${installDir}/bin
    chmod g+rx ${installDir}/bin
    chmod g+r ${installDir}/bin/sentinelone-agent
    for p in home lib configuration/sentineld configuration/sentinelone.service ebpfs; do
      [ -e ${installDir}/$p ] && chown -R root:root ${installDir}/$p
    done
    echo -n "${s1.version}" > "$marker"
  '';

  enroll = pkgs.writeShellScript "sentinelone-enroll" ''
    set -eu
    done_marker=${installDir}/.nix-enrolled
    [ -e "$done_marker" ] && exit 0
    # attend que l'agent réponde
    for _ in $(seq 1 30); do
      ${ctl} control status >/dev/null 2>&1 && break
      sleep 2
    done
    ${ctl} management token set "$(cat ${config.age.secrets.sentinelone-token.path})"
    ${ctl} control start || true
    touch "$done_marker"
  '';
in
{
  age.secrets.sentinelone-token.file = "${flakeRoot}/secrets/lunar-sentinelone-token.age";

  users.groups.sentinelone = { };
  users.users.sentinelone = {
    isSystemUser = true;
    group = "sentinelone";
    home = "${installDir}/home";
    shell = "${pkgs.shadow}/bin/nologin";
  };

  # Les binaires sont dynamiques (glibc, libgcc_s) : nix-ld fournit l'interpréteur.
  programs.nix-ld.libraries = [ pkgs.stdenv.cc.cc.lib ];

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "sentinelctl" ''exec ${ctl} "$@"'')
  ];

  systemd.services.sentinelone = {
    description = "Monitor SentinelOne Agent";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [
      coreutils
      kmod
      util-linux
    ];
    # Un redémarrage au switch couperait la protection : on ne touche pas au service.
    restartIfChanged = false;
    unitConfig = {
      StartLimitIntervalSec = 90;
      StartLimitBurst = 4;
    };
    serviceConfig = {
      Type = "exec";
      WorkingDirectory = "${installDir}/bin";
      ExecStartPre = "+${sync}";
      ExecStart = "${installDir}/bin/sentinelone-agent";
      ExecStop = "${ctl} control stop";
      Restart = "on-failure";
      RestartSec = 4;
      MemoryAccounting = true;
      TasksMax = "infinity";
      NotifyAccess = "all";
      # Le .deb impose WatchdogSec=30s : omis ici (non testé sous NixOS), l'agent
      # a son propre watchdog (sentinelone-watchdog).
    };
  };

  systemd.services.sentinelone-enroll = {
    description = "Enrôlement SentinelOne (token agenix)";
    wantedBy = [ "multi-user.target" ];
    after = [ "sentinelone.service" ];
    requires = [ "sentinelone.service" ];
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${enroll}";
    };
  };
}
