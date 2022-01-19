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
    settings.concurrentTasks = 6;
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:blitz/nix-config";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "performance";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  networking.hostName = "first-temple"; # Define your hostname.

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  networking.firewall.enable = false;

  networking.networkmanager.enable = false;

  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.julian = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+gIoZzLre6Bnw/G8mpv7M9i1sjEmkswRGUqy+l+K4C julian@solomon.localdomain"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErZm6k0S7NahikKEbTQlrOrsLKgr9X+iNoUsGeqDV0F julian@canaan.xn--pl-wia.net"
    ];
    hashedPassword = "$6$d4Q85PrE$m/mrZqoe6R4oi.2NHoB6gJicQr85yKtnmZBXUeyap7KPGKCp9SLqfPOprY12cJtjCcM3bsXTUVzS3O6n8VNTx0";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
