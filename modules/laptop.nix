{ config, pkgs, lib, ... }: {

  imports = [
    ./gnome3.nix
    ./common.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true;

  powerManagement.cpuFreqGovernor = "schedutil";
}
