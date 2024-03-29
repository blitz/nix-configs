# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b2f746b9-1ae8-43bc-b6b1-39fe4ba0e43b";
      fsType = "xfs";
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/7f9ebda7-2631-4bb0-9e4a-88737c88d4df";
  boot.initrd.luks.devices."cryptroot".allowDiscards = true;

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F165-96AC";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/cf1cb3e8-2d36-45de-8854-14677197ec7c"; }
    ];

}
