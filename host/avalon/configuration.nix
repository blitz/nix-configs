# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../../modules/laptop.nix
      ../../modules/amdgpu.nix
      ../../modules/cachix.nix
      ../../modules/coding.nix
      ../../modules/work.nix
      ../../modules/tailscale-client.nix
      ../../modules/home-manager.nix
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

  nixpkgs = {
    overlays = [
      (self: super: {
        linuxPackages_latest = self.linuxPackagesFor ((super.linuxPackages_latest.kernel.override {
          stdenv = pkgs.llvmPackages_latest.stdenv;

          structuredExtraConfig = with lib.kernel; {
            # LIVEPATCH = yes;

            # TODO This currently fails, because we need the build
            # process to use lld instead of the bfd linker.
            #
            # LTO_CLANG_FULL = yes;

            # This kernel is only used on baremetal.
            HYPERVISOR_GUEST = lib.mkForce no;
            PARAVIRT = lib.mkForce no;

            # Not used.
            FTRACE = lib.mkForce no;
            KPROBES = lib.mkForce no;

            # Not strictly necessary, but not useful on AMD either.
            X86_INTEL_MEMORY_PROTECTION_KEYS = lib.mkForce no;
            X86_USER_SHADOW_STACK = lib.mkForce no;
            X86_CET = lib.mkForce no;

            # No need to dynamically set this.
            PREEMPT_DYNAMIC = no;
          };

          # There are lots of PARAVIRT-related options that don't apply, if we disable PARAVIRT.
          ignoreConfigErrors = true;
        }).overrideAttrs (old: {
          # Breaks with clang otherwise:
          #
          # error: argument unused during compilation: '-fno-strict-overflow'
          hardeningDisable = old.hardeningDisable ++ [ "strictoverflow" ];
        }));
      })
    ];
  };

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
