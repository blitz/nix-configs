# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  js = import /home/julian/src/own/nix-configs;
in
{
  imports = [
    <nixos-hardware/lenovo/thinkpad/x250>
    ./hardware-configuration.nix
    ./cachix.nix
    js.modules.common
    js.modules.gnome3
    js.modules.laptop
  ];

  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;

  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.buildMachines = [
    {
      hostName = "eu.nixbuild.net";
      maxJobs = 10;
      sshKey = "/root/.ssh/id_ed25519";
      sshUser = "root";
      supportedFeatures = [ "big-parallel" "benchmark" ];
      systems = [ "x86_64-linux" ];
      speedFactor = 2;
    }
  ];

  powerManagement.cpuFreqGovernor = "ondemand";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/".options = [ "rw" "discard" "relatime" ];
  boot.initrd.luks.devices."root".allowDiscards = true;

  networking.hostName = "canaan";
  networking.domain = "localhost";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
  system.autoUpgrade.enable = true;
}
