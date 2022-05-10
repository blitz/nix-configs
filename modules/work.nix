{ config, pkgs, lib, ... }: {

  programs.evolution = {
    enable = true;
    plugins = [ pkgs.evolution-ews ];
  };

  environment.systemPackages = with pkgs; [
    picocom
    delta
    libreoffice-fresh
    kooha
    mattermost-desktop
  ];

  services = {
    onedrive.enable = true;

    dhcpd4 = {
      enable = true;
      interfaces = [ "enp53s0" ];

      extraConfig = ''
      default-lease-time 600;
      max-lease-time 7200;

      allow booting;
      allow bootp;

      option arch code 93 = unsigned integer 16; # RFC4578

      subnet 192.168.99.0 netmask 255.255.255.0 {
        range dynamic-bootp 192.168.99.100 192.168.99.253;
        option routers 192.168.99.1;
        next-server 192.168.99.1;

        option root-path "";

        # Speed up DHCP if no ProxyDHCP is in the network.
        # option ipxe.no-pxedhcp 1;

        class "UEFI-64-1" {
          match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00007";
          filename "ipxe.efi";
        }

        class "UEFI-64-2" {
          match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00008";
          filename "ipxe.efi";
        }

        class "UEFI-64-3" {
          match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00009";
          filename "ipxe.efi";
        }

        class "Legacy" {
          match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00000";
          filename "ipxe.kpxe";
        }

        host testnuc    { hardware ethernet d4:5d:df:13:53:97; fixed-address 192.168.99.3; }
        host testoldnuc { hardware ethernet b8:ae:ed:75:8a:bd; fixed-address 192.168.99.4; }
        host testsonuc  { hardware ethernet 94:c6:91:10:68:09; fixed-address 192.168.99.5; }
        host atomnuc    { hardware ethernet b4:2e:99:bf:01:a0; fixed-address 192.168.99.6; }
        host serialnuc  { hardware ethernet f4:4d:30:6f:0a:00; fixed-address 192.168.99.7; }
      }
    '';
    };

    atftpd = {
      enable = true;
      root = "/home/julian/Public/tftp";
      extraOptions = [ "--bind-address 192.168.99.1" ];
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      unmanaged = [ "enp53s0" ];
    };

    interfaces.enp53s0 = {
      useDHCP = false;

      ipv4.addresses = [
        {
          address = "192.168.99.1";
          prefixLength = 24;
        }
      ];
    };
  };
}
