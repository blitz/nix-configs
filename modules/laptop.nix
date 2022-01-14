{ config, pkgs, lib, ... }: {

  imports = [
    ./gnome3.nix
    ./common.nix
  ];

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = false;
  hardware.bluetooth.powerOnBoot = false;

  powerManagement.cpuFreqGovernor = "schedutil";
}
