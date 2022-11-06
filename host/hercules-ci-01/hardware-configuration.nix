# A configuration for a Hetzner VM that was created via nixos-infect.
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  networking.hostName = "hercules-ci-01";

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErZm6k0S7NahikKEbTQlrOrsLKgr9X+iNoUsGeqDV0F julian@canaan.xn--pl-wia.net"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeIiTyh7jJD9x8N64kgUGDgeo3F96i5Av3tHvwePHq5 julian@babylon"
  ];

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  networking.interfaces.enp1s0.ipv6.addresses = [ {
    address = "2a01:4f8:c012:7047::2";
    prefixLength = 64;
  } ];

  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp1s0";
  };

  system.stateVersion = "22.05";
}
