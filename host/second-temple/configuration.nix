# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../../modules/common.nix

      # Nixbuild seems to be ratelimited by crates.io, which breaks builds.
      #../../modules/nixbuild.nix

      ../../modules/cachix.nix
    ];

  # To build cross-platform binaries.
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv32-linux"
    "riscv64-linux"
  ];

  services.hercules-ci-agent = {
    enable = true;
    settings.concurrentTasks = 4;
  };

  # Nix 2.8.1 has problems with Hercules CI.
  nix.package = pkgs.nixUnstable;

  # The XFS FAQ suggests to use no I/O scheduler.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
  '';

  system.autoUpgrade = {
    enable = true;
    flake = "github:blitz/nix-configs";
    flags = [
      " --no-write-lock-file"
    ];
  };

  powerManagement.cpuFreqGovernor = "performance";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "second-temple"; # Define your hostname.

  # We use Wi-Fi via Network Manager.
  networking.networkmanager.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This box is not exposed to the internet.
  networking.firewall.enable = false;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.05"; # Did you read the comment?
}
