{ config, pkgs, ... }:

{
  imports = [
    ../../modules/laptop.nix
    #../../modules/obs-studio.nix
    ../../modules/cachix.nix
    ../../modules/nixbuild.nix
    ../../modules/rust-dev.nix
  ];

  boot.extraModprobeConfig = ''
    options kvm-amd avic=1
  '';

  powerManagement.powertop.enable = true;

  boot.kernelParams = [
    # Force use of the thinkpad_acpi driver for backlight control.
    # This allows the backlight save/load systemd service to work.
    "acpi_backlight=native"
  ];

  boot.kernelPatches = [
    # {
    #   name = "think-lmi-fwupd-compat";
    #   patch = ../../patches/linux/0001-platform-x86-think-lmi-expose-type-attribute.patch;
    # }
  ];

  # For building Raspberry Pi system images. Disabled for now, because
  # we have nixbuild.net.
  #
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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

  services.power-profiles-daemon.enable = true;

  # Use the systemd-boot EFI boot loader.

  # XXX Disabled for lanzaboote.
  boot.loader.systemd-boot.enable = false;

  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "canaan";
  networking.domain = "localhost";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
