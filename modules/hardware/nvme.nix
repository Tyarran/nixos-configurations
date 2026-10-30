{ ... }:

{
  # NVMe SSD I/O optimizations
  # Default scheduler is 'none' which is optimal for NVMe
  # But we can tune other parameters

  services.udev.extraRules = ''
    # NVMe I/O scheduler and queue optimizations
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/read_ahead_kb}="256"
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nr_requests}="1024"
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/rq_affinity}="2"
  '';
}
