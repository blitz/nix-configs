# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ../../modules/common.nix
      ../../modules/tailscale-exit-node.nix
      ../../modules/cachix.nix
      ../../modules/home-manager.nix
    ];

  # For cross-platform builds.
  boot.binfmt.emulatedSystems = [
    # We have third-temple for this.
    # "aarch64-linux"

    "riscv32-linux"
    "riscv64-linux"
  ];

  # https://github.com/nix-community/home-manager/issues/3113
  programs.dconf.enable = true;

  services.openssh.enable = true;

  services.hercules-ci-agent = {
    enable = true;
    settings.concurrentTasks = 2;
  };

  nix.gc = {
    automatic = true;
    dates = "monthly";
  };

  nix.settings.system-features = [
    "kvm" "nixos-test" "big-parallel" "benchmark"
    "gccarch-x86-64-v2" "gccarch-x86-64-v3"
  ];

  # The XFS FAQ suggests to use no I/O scheduler.
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="[sv]d[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
  '';

  system.autoUpgrade.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "first-temple"; # Define your hostname.

  networking.networkmanager.enable = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}
