{ ... }: {
  networking.useNetworkd = true;

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "ipv4";
    address = [
      "2a01:4f8:c013:4e4d::1/64"
    ];
    routes = [
      { routeConfig.Gateway = "fe80::1"; }
    ];
  };

}
