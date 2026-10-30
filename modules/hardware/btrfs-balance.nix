# Balance btrfs légère, mensuelle, sur /.
{ pkgs, ... }:

{
  systemd.services.btrfs-balance = {
    description = "Light Btrfs balance on /";
    unitConfig.ConditionPathIsMountPoint = "/";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
      ExecStart = "${pkgs.btrfs-progs}/bin/btrfs balance start -dusage=30 -musage=30 /";
    };
  };

  systemd.timers.btrfs-balance = {
    description = "Monthly light Btrfs balance on /";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "monthly";
      AccuracySec = "1d";
      RandomizedDelaySec = "1w";
      Persistent = true;
    };
  };
}
