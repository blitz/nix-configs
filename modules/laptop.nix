{ config, pkgs, lib, ... }: {

  imports = [
    ./gnome3.nix
    ./common.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPatches = [
  #   # {
  #   #   name = "thinkpad-l14-temp11";
  #   #   patch = ./thinkpad-l14-temp11.patch;
  #   # }

  #   {
  #     name = "thinkpad-l14-temp-labels";
  #     patch = ./thinkpad-l14-temp-labels.patch;
  #   }
  # ];

  hardware.opengl.extraPackages = [
    # OpenCL
    # pkgs.rocm-opencl-runtime
    pkgs.rocm-opencl-icd
    # AMD's Vulkan Driver
    # pkgs.amdvlk
  ];

  hardware.opengl.extraPackages32 = [
    # pkgs.driversi686Linux.amdvlk
  ];

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = false;
  hardware.bluetooth.powerOnBoot = false;

  powerManagement.cpuFreqGovernor = "schedutil";
}
