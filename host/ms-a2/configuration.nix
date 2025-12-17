# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [
      ../../modules/common.nix
      ../../modules/secure-boot.nix
      #../../modules/awesome-kernel.nix
      ../../modules/gnome3.nix
      ../../modules/amdgpu.nix
      ../../modules/cachix.nix
      ../../modules/coding.nix
      ../../modules/work.nix
      ../../modules/tailscale-client.nix
      ../../modules/home-manager.nix
      # ../../modules/keybase.nix
      # ../../modules/aarch64-remote.nix
      ../../modules/obs-studio.nix
      #../../modules/testing-keycloak.nix
      #../../modules/testing-authentik.nix
      ../../modules/lix.nix
      ../../modules/niri.nix      

      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-gpu-amd
    ];

  # AMD GPU driver issues...
  #
  # https://gitlab.freedesktop.org/drm/amd/-/issues/4592
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;

  networking.networkmanager = {
    enable = true;
    unmanaged = [
      # "enp4s0"
    ];
  };

  systemd.network.enable = true;
  systemd.network.wait-online.enable = false;

  networking = {
    useNetworkd = true;
    useDHCP = false;
    # interfaces.enp4s0.useDHCP = true;
  };


  powerManagement.cpuFreqGovernor = "schedutil";

  # Quiet boot
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet" "udev.log_level=3"
  ] ;

  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;

  # Who doesn't like fast virtualization.
  boot.extraModprobeConfig = ''
    options kvm-amd avic=1
  '';

  services.power-profiles-daemon.enable = true;

  # We use lanzaboote.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;

  networking.hostName = "ms-a2";
  networking.domain = "localhost";

  nix.settings.system-features = [
    "kvm" "nixos-test" "big-parallel" "benchmark"
    "gccarch-znver2" "gccarch-znver3"
    "gccarch-x86-64-v2" "gccarch-x86-64-v3"
  ];

  disko.devices = {
    disk = {
      ms-a2 = {
        device = "/dev/nvme0n1";
        type = "disk";

        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "2000M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            encrypted_root = {
              size = "100%";
              content = {
                type = "luks";
                name = "root";
                settings.allowDiscards = true;
                content = {
                  type = "filesystem";
                  format = "xfs";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "thunderbolt" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  hardware.cpu.amd.updateMicrocode = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
