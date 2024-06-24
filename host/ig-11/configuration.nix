# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ../../modules/common.nix
      ../../modules/gnome3.nix
      ../../modules/cachix.nix
      ../../modules/games.nix
      ../../modules/coding.nix
      ../../modules/tailscale-client.nix
      ../../modules/home-manager.nix
    ];

  networking.networkmanager.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  # Quiet boot
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet" "udev.log_level=3"
  ] ;

  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;

  #hardware.amdgpu.opencl.enable = true;

  # Who doesn't like fast virtualization.
  boot.extraModprobeConfig = ''
    options kvm-amd avic=1
  '';

  services.power-profiles-daemon.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;

  networking.hostName = "ig-11";
  networking.domain = "localhost";

  nix.settings.system-features = [
    "kvm" "nixos-test" "big-parallel" "benchmark"
    "gccarch-znver2" "gccarch-znver3"
    "gccarch-x86-64-v2" "gccarch-x86-64-v3"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
