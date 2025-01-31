{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    tcpdump
  ];
  
  networking.networkmanager.unmanaged = [ "eth0" ];

  systemd.network = {
    enable = true;
    wait-online.enable = false;

    
    networks."10-eth0" = {
      matchConfig.Name = "eth0";

      # Set a static IP for the interface
      address = [ "192.168.111.1/24" ];

      networkConfig = {
        DHCPServer = "yes";
        IPMasquerade = "ipv4";
      };

      # Enable DHCP server
      dhcpServerConfig = {
        PoolOffset = 10;
        PoolSize = 50;
        EmitDNS = true;
        DNS = [ "8.8.8.8" ];
        EmitRouter = true;
      };
    };
  };
}
