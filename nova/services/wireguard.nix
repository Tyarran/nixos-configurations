{ ... }:

{
  # WireGuard VPN configuration (commented out)
  # networking.wg-quick.interfaces = {
  #   wg0 = {
  #     address = [ "192.168.27.66/32" ];
  #     # use dnscrypt, or proxy dns as described above
  #     dns = [ "212.27.38.253" ];
  #     privateKeyFile = "/etc/rcommande-vpn.key";
  #     peers = [
  #       {
  #         # bt wg conf
  #         publicKey = "zf2hHepPuONKhyAkuHl/oDkzuBHhgoEzIj9gBgHy7G0=";
  #         allowedIPs = [ "0.0.0.0/0" "192.168.27.64/27" "192.168.1.0/24" ];
  #         endpoint = "82.67.94.171:30087";
  #       }
  #     ];
  #   };
  # };
}
