{ ... }:

{
  services.samba = {
    enable = true;
    settings = {
      global = {
        security = "user";
        workgroup = "WORKGROUP";
        "map to guest" = "bad user";
        "min protocol" = "SMB2";
        "server signing" = "auto";
        "passdb backend" = "tdbsam";
      };
      "Storage" = {
        "path" = "/srv/storage/Storage";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "@samba";
        "write list" = "@samba";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "romain";
        "force group" = "samba";
      };
    };
  };

  services.samba-wsdd.enable = true;

  networking.firewall.allowedTCPPorts = [
    139
    445
  ];
  networking.firewall.allowedUDPPorts = [
    137
    138
  ];
}
