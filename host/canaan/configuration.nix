{ input, ... }: {

  imports =
    [
      ../../modules/thinkpad-l14-amd.nix
      ../../modules/laptop.nix
      ../../modules/amdgpu.nix
      ../../modules/cachix.nix
      ../../modules/coding.nix
      ../../modules/tailscale-client.nix
      ../../modules/home-manager.nix
    ];

  boot.initrd.availableKernelModules = [
    # TODO trim down later
    "nvme" "ehci_pci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "ahci" "uas" "sdhci_pci"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "canaan";

  disko.devices = {
    disk = {
      canaan = {
        device = "/dev/nvme0n1";
        type = "disk";

        imageSize = "40G";

        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "2000M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              name = "root";
              end = "-0";
              size = "100%";
              content = {
                type = "filesystem";
                format = "bcachefs";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };

  system.stateVersion = "24.11";
}
