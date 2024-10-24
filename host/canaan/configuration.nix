{ config, pkgs, ... }:

{
  imports = [
    ../../modules/secure-boot.nix
    ../../modules/thinkpad-l14-amd.nix
    ../../modules/laptop.nix
    ../../modules/amdgpu.nix
    #../../modules/obs-studio.nix
    ../../modules/cachix.nix
    ../../modules/nixbuild.nix
    ../../modules/coding.nix
    ../../modules/tailscale-client.nix
    #../../modules/games.nix
    ../../modules/home-manager.nix
  ];

  # Quiet boot
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet" "udev.log_level=3"
  ];

  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;

  # Who doesn't like fast virtualization.
  boot.extraModprobeConfig = ''
    options kvm-amd avic=1
  '';

  powerManagement.powertop.enable = true;

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

  nix.settings.system-features = [
    "kvm" "nixos-test" "big-parallel" "benchmark"
    "gccarch-znver2"
    "gccarch-x86-64-v2" "gccarch-x86-64-v3"
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
