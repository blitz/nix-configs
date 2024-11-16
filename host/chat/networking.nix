{ lib, ... }: {
  networking.useNetworkd = true;

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "ipv4";
    address = [
      "2a01:4f8:c012:c2b5::1/64"
    ];
    routes = [
      { Gateway = "fe80::1"; }
    ];
  };

}
