# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../../modules/laptop.nix
      ../../modules/cachix.nix
      ../../modules/coding.nix
      ../../modules/work.nix
      ../../modules/tailscale-client.nix
      #../../modules/games.nix
      ../../modules/home-manager.nix
      ../../modules/intel-sriov.nix
    ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  boot.kernelParams = [
    #"split_lock_detect=off"
  ];

  boot.kernelPatches = [
    {
      name = "builtin-cmdline";
      patch = ../../patches/linux/0001-x86-boot-Pull-up-cmdline-preparation-again.patch;
      extraStructuredConfig = {
        CMDLINE_BOOL = lib.kernel.yes;
        CMDLINE = lib.kernel.freeform "split_lock_detect=off";
      };
    }
  ];

  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "babylon";

  fileSystems."/".options = [ "rw" "discard" "relatime" ];
  boot.initrd.luks.devices."nixos-root".allowDiscards = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

