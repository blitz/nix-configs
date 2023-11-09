{ config, pkgs, lib, ... }: {

  nix = {
    settings.trusted-public-keys = [
      "cyberus-1:0jjMD2b+guloGW27ZToxDQApCoWj+4ONW9v8VH/Bv0Q="
      "binary-cache.vpn.cyberus-technology.de:qhg25lVqyCT4sDOqxY6GJx8NF3F86eAJFCQjZK/db7Y="
    ];

    settings.substituters = [
      "http://binary-cache-v2.vpn.cyberus-technology.de"

      # Too slow for normal use.
      # "https://binary-cache.vpn.cyberus-technology.de"
    ];

    extraOptions = ''
      extra-substituters = http://binary-cache-v2.vpn.cyberus-technology.de
   '';

    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "remote-builder.vpn.cyberus-technology.de";
        sshUser = "builder";
        systems = [ "x86_64-linux" "aarch64-linux" ];
        maxJobs = 8;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
    ];
  };

  programs.ssh = {
    extraConfig = ''
      Host remote-builder.vpn.cyberus-technology.de
        PubkeyAcceptedKeyTypes ssh-ed25519
        IdentityFile ~/.ssh/id_ed25519
    '';

    knownHosts = {
      nixbuild = {
        hostNames = [ "remote-builder.vpn.cyberus-technology.de" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwdIPCDHFhao84ZoHgphp+hzYH9ot+L2gSDFD8HrMyw";
      };
    };
  };

  boot.loader.systemd-boot.extraEntries."svp.conf" = ''
     title SVP
     efi /svp/loader.efi
  '';

  programs.evolution = {
    enable = true;
    plugins = [ pkgs.evolution-ews ];
  };

  environment.systemPackages = with pkgs; [
    picocom
    delta
    _1password-gui

    # For Intel AMT.
    #
    # Meshcommander will listen on http://127.0.0.1:3000
    nodePackages.meshcommander

    # To avoid Intel AMT
    remmina
  ] ++ (
    let
      qemuUefi = pkgs.writeShellScriptBin "qemu-uefi" ''
        exec ${pkgs.qemu}/bin/qemu-system-x86_64 \
              -machine q35,accel=kvm -cpu host -bios ${pkgs.OVMFFull.fd}/FV/OVMF.fd \
              -m 4096 -display none -serial stdio "$@"
      '';
      qemuUefiTftp = pkgs.writeShellScriptBin "qemu-uefi-tftp" ''
        exec ${qemuUefi}/bin/qemu-uefi \
              -boot n -device virtio-net,netdev=n1 -netdev user,id=n1,tftp=$HOME/Public/tftp,bootfile=ipxe.efi \
              "$@"
        '';
    in [
      qemuUefi
      qemuUefiTftp
    ]
  );

  # The damn libvirtd dnsmasq binds to all devices on the DHCP port.
  # systemd.services.kea-dhcp4-server.before = [ "libvirtd.service" ];

  services = {
    onedrive.enable = true;

    kea.dhcp4 = {
      # enable = true;
      configFile = ./work-kea-dhcp4.json;
    };

    dhcpd4 = {
      # enable = true;

      interfaces = [ "enp53s0" ];

      extraConfig = ''
      default-lease-time 600;
      max-lease-time 7200;

      allow booting;
      allow bootp;

      option arch code 93 = unsigned integer 16; # RFC4578

      option space ipxe;
      option ipxe-encap-opts code 175 = encapsulate ipxe;
      option ipxe.priority code 1 = signed integer 8;
      option ipxe.keep-san code 8 = unsigned integer 8;
      option ipxe.skip-san-boot code 9 = unsigned integer 8;
      option ipxe.syslogs code 85 = string;
      option ipxe.cert code 91 = string;
      option ipxe.privkey code 92 = string;
      option ipxe.crosscert code 93 = string;
      option ipxe.no-pxedhcp code 176 = unsigned integer 8;
      option ipxe.bus-id code 177 = string;
      option ipxe.san-filename code 188 = string;
      option ipxe.bios-drive code 189 = unsigned integer 8;
      option ipxe.username code 190 = string;
      option ipxe.password code 191 = string;
      option ipxe.reverse-username code 192 = string;
      option ipxe.reverse-password code 193 = string;
      option ipxe.version code 235 = string;
      option iscsi-initiator-iqn code 203 = string;
      # Feature indicators
      option ipxe.pxeext code 16 = unsigned integer 8;
      option ipxe.iscsi code 17 = unsigned integer 8;
      option ipxe.aoe code 18 = unsigned integer 8;
      option ipxe.http code 19 = unsigned integer 8;
      option ipxe.https code 20 = unsigned integer 8;
      option ipxe.tftp code 21 = unsigned integer 8;
      option ipxe.ftp code 22 = unsigned integer 8;
      option ipxe.dns code 23 = unsigned integer 8;
      option ipxe.bzimage code 24 = unsigned integer 8;
      option ipxe.multiboot code 25 = unsigned integer 8;
      option ipxe.slam code 26 = unsigned integer 8;
      option ipxe.srp code 27 = unsigned integer 8;
      option ipxe.nbi code 32 = unsigned integer 8;
      option ipxe.pxe code 33 = unsigned integer 8;
      option ipxe.elf code 34 = unsigned integer 8;
      option ipxe.comboot code 35 = unsigned integer 8;
      option ipxe.efi code 36 = unsigned integer 8;
      option ipxe.fcoe code 37 = unsigned integer 8;
      option ipxe.vlan code 38 = unsigned integer 8;
      option ipxe.menu code 39 = unsigned integer 8;
      option ipxe.sdi code 40 = unsigned integer 8;
      option ipxe.nfs code 41 = unsigned integer 8;

      option user-class code 77 = string;

      subnet 192.168.99.0 netmask 255.255.255.0 {
        range dynamic-bootp 192.168.99.100 192.168.99.253;
        option routers 192.168.99.1;
        next-server 192.168.99.1;

        option root-path "";

        option domain-name-servers 8.8.8.8, 8.8.4.4;

        # Speed up DHCP if no ProxyDHCP is in the network.
        option ipxe.no-pxedhcp 1;

        class "iPXE" {
          match if exists user-class and option user-class = "iPXE";
          filename "ipxe-default.cfg";
        }

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

        host thinkstat  { hardware ethernet 38:f3:ab:f7:51:9d; fixed-address 192.168.99.9; }
        host thinkstat2 { hardware ethernet e8:80:88:27:64:40; fixed-address 192.168.99.10; }
      }
    '';
    };

    atftpd = {
      # We are test driving obiwan for now.
      # enable = true;
      root = "/home/julian/Public/tftp";
      extraOptions = [ "--bind-address 192.168.99.1" ];
    };

    obiwan = {
      # enable = true;

      root = "/home/julian/Public/tftp";
      listenAddress = "192.168.99.1";
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

    # Offer Internet.
    nat = {
      enable = true;
      externalInterface = "wlp54s0";
      internalInterfaces = [ "enp53s0" ];
    };
  };

  # Elm development hacks
  services.nginx = {
    # enable = true;
    defaultListenAddresses = [ "127.0.0.1" "[::1]" ];
    defaultHTTPListenPort = 3001;

    virtualHosts."localhost" =  {
      locations."/" = {
        proxyPass = "http://sotest:3000";
        extraConfig = ''
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
  };
}
