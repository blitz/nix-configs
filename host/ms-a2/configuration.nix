# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  self,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/common.nix
    ../../modules/secure-boot.nix
    ../../modules/gnome3.nix
    ../../modules/amdgpu.nix
    ../../modules/cachix.nix
    ../../modules/coding.nix
    ../../modules/work.nix
    ../../modules/tailscale-client.nix
    ../../modules/home-manager.nix
    # ../../modules/aarch64-remote.nix
    ../../modules/obs-studio.nix
    ../../modules/lix.nix
    ../../modules/niri.nix
    ../../modules/secrets.nix
    ../../modules/hercules-ci-worker.nix

    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  blitz.common.system-role = "client";
  blitz.amdgpu.hwVideoEncoding = true;

  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true; # builder downloads from caches itself

  nix.buildMachines =
    let
      server = self.nixosConfigurations.first-temple;
    in
    [
      {
        hostName = "first-temple.lan";
        protocol = "ssh-ng";
        sshUser = "nix-ssh";

        # TODO add to agenix
        sshKey = "/etc/nix/builder_ed25519"; # private key, used by root's nix-daemon

        systems = [ "x86_64-linux" ];
        maxJobs = 2;
        speedFactor = 2;
        supportedFeatures = server.nix.settings.system-features;

        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUVscVh4LzZlQjFNWXNoNGNWcDlmNHBMcndvd1JtNFdzRjdpd2E2Zk9xT1kgcm9vdEBuaXhvcwo=";
      }
    ];

  systemd.network.enable = true;
  systemd.network.wait-online.enable = false;

  networking = {
    useNetworkd = true;
    useDHCP = false;
    interfaces.enp3s0.useDHCP = true;
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  boot.kernelParams = [
    # Suggested by Minisforum support for PCIe link errors.
    "pcie_aspm=off"
    "pcie_port_pm=off"
    "nvme_core.default_ps_max_latency_us=0"
  ];

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

  nix.settings = {
    experimental-features = [
      "auto-allocate-uids"
      "cgroups"
    ];

    auto-allocate-uids = true;
    use-cgroups = true;

    system-features = [
      "uid-range"
      "kvm"
      "nixos-test"
      "big-parallel"
      "benchmark"
      "gccarch-znver2"
      "gccarch-znver3"
      "gccarch-x86-64-v2"
      "gccarch-x86-64-v3"
    ];
  };

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

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  hardware.cpu.amd.updateMicrocode = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
