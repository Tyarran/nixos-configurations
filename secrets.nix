let
  nova = "age1gv85lzqxvd35fjmng4n3aafclqgm4gsfq5nq3k5ue2m0a4qqdeqq085msl";
  orion = "age1emw7j34yfy03ry368065m3ftm7mynpq8gp20tqkz3z3krcxjugusq5nfkk";
  lunar = "age1derst6zjfw7gpq5yy6kkqfnugksg9djz4gn0047dncxaekl9e55sv85dxs";
in
{
  "secrets/orion-romain-password.age".publicKeys = [
    nova
    orion
  ];
  "secrets/nova-romain-password.age".publicKeys = [ nova ];
  "secrets/orion-immich-db-password.age".publicKeys = [
    nova
    orion
  ];
  "secrets/orion-scaleway-access-key.age".publicKeys = [
    nova
    orion
  ];
  "secrets/orion-scaleway-secret-key.age".publicKeys = [
    nova
    orion
  ];
  "secrets/orion-backup-password.age".publicKeys = [
    nova
    orion
  ];
  "secrets/lunar-romain-password.age".publicKeys = [ lunar ];
  "secrets/lunar-sentinelone-token.age".publicKeys = [ lunar ];
  "secrets/lunar-vanta-conf.age".publicKeys = [ lunar ];
}
