{ config, pkgs, lib, ... }: {

  imports = [
    ./gnome3.nix
    ./common.nix
  ];

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
