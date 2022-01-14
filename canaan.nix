{ config, pkgs, ... }:

{
  imports = [
    ./modules/laptop.nix
    ./modules/obs-studio.nix
    ./cachix.nix
    ./nixbuild.nix
  ];

  boot.extraModprobeConfig = ''
    options kvm-amd avic=1
  '';

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # For building Raspberry Pi system images.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.opengl.extraPackages = [
    # OpenCL
    pkgs.rocm-opencl-runtime
    pkgs.rocm-opencl-icd
    # AMD's Vulkan Driver
    pkgs.amdvlk
  ];

  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];


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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "canaan";
  networking.domain = "localhost";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
