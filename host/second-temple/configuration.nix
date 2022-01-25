# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../../modules/common.nix
      ../../modules/nixbuild.nix
      ../../modules/cachix.nix
    ];

  services.hercules-ci-agent = {
    enable = true;

    # We rely on nixbuild taking the brunt.
    settings.concurrentTasks = 5;
  };

  # The XFS FAQ suggests to use no I/O scheduler.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
  '';

  system.autoUpgrade = {
    enable = true;
    flake = "github:blitz/nix-configs";
  };

  powerManagement.cpuFreqGovernor = "performance";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "second-temple"; # Define your hostname.

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  networking.firewall.enable = false;

  networking.networkmanager.enable = false;

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11"; # Did you read the comment?
}