# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../../modules/secure-boot.nix
      ../../modules/laptop.nix
      ../../modules/amdgpu.nix
      ../../modules/cachix.nix
      ../../modules/coding.nix
      ../../modules/work.nix
      ../../modules/tailscale-client.nix
      ../../modules/home-manager.nix
      ../../modules/keybase.nix
    ];

  fileSystems."/".options = [ "rw" "discard" "relatime" ];
  boot.initrd.luks.devices."luks-a226c66b-7561-47cd-96c2-3b24a7a92220".allowDiscards = true;

  # Quiet boot
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
  ];

  boot.extraModprobeConfig = ''
    # Who doesn't like fast virtualization. But AVIC may be buggy...
    #  avic=1 force_avic=1
    options kvm-amd nested=1
  '';

  boot.kernelPatches = [
    {
      name = "crashdump-config";
      patch = null;
      extraStructuredConfig = with lib.kernel; {
        # kpatch is not able to handle IBT yet.
        X86_KERNEL_IBT = lib.mkForce no;

        LIVEPATCH = yes;
      };

      # There is some fallout from disabling PARAVIRT.
      ignoreConfigErrors = true;
    }
  ];

  # Not needed anymore since 6.11 for AMD.
  hardware.framework.enableKmod = false;

  # Bootloader. We use lanzaboote.
  # boot.loader.systemd-boot.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "avalon";

  nix.settings.system-features = [
    "kvm"
    "nixos-test"
    "big-parallel"
    "benchmark"
    "gccarch-znver2"
    "gccarch-znver3"
    "gccarch-znver4"
    "gccarch-x86-64-v2"
    "gccarch-x86-64-v3"
    "gccarch-x86-64-v4"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
