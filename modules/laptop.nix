{ config, pkgs, lib, ... }: {

  imports = [
    ./gnome3.nix
    ./common.nix
  ];

  boot.extraModprobeConfig = ''
    options kvm-amd avic=1
  '';

  # TODO Settings in the power daemon are not persistent? Or they
  # don't have any effect.
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;

  services.thinkfan = {
    enable = true;
    levels = [
      [0  0   55]
      [1  50  65]
      [2  60  68]
      [3  65  72]
      [4  67  75]
      [5  68  78]
      [6  69  79]
      [7  70  80]
      [127 78 32767]
    ];

    # Disble bias because it causes annoying spinups of the fan.
    extraArgs = [ "-b" "0" ];
    #sensors = "tp_thermal /proc/acpi/ibm/thermal";
  };

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
