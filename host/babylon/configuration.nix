# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ../../modules/laptop.nix
      ../../modules/obs-studio.nix
      ../../modules/cachix.nix
    ];

  nixpkgs.config.allowUnfree = true;
  hardware.tuxedo-control-center.enable = true;
  nix = {
    binaryCachePublicKeys = [
      "binary-cache.vpn.cyberus-technology.de:qhg25lVqyCT4sDOqxY6GJx8NF3F86eAJFCQjZK/db7Y="
    ];
    trustedBinaryCaches = [ "https://binary-cache.vpn.cyberus-technology.de" ];
    extraOptions = ''
      extra-substituters = https://binary-cache.vpn.cyberus-technology.de
   '';
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

