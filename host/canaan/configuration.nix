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
      ../../modules/secure-boot.nix
      ../../modules/quiet-boot.nix
    ];


  hardware.wirelessRegulatoryDatabase = true;

  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="ES"
  '';

  boot.initrd.availableKernelModules = [
    # TODO trim down later
    "nvme" "ehci_pci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "ahci" "uas" "sdhci_pci"
  ];

  # Bootloader. We use lanzaboote.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote.pkiBundle = "/var/lib/sbctl";


  services.thinkfan = {
    enable = true;
    levels = [
      [0  0   55]
      [1  50  65]
      [2  60  68]
      [3  65  72]
      [4  67  75]
      [5  68  78]
      [6  69  79]
      [7  70  80]
      [127 78 32767]
    ];

    # Disble bias because it causes annoying spinups of the fan.
    extraArgs = [ "-b" "0" ];
    #sensors = "tp_thermal /proc/acpi/ibm/thermal";
  };

  services.power-profiles-daemon.enable = true;

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
