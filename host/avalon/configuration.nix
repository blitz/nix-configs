# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ../../modules/laptop.nix
      ../../modules/cachix.nix
      ../../modules/coding.nix
      ../../modules/work.nix
      ../../modules/tailscale-client.nix
      ../../modules/home-manager.nix
    ];

  fileSystems."/".options = [ "rw" "discard" "relatime" ];
  boot.initrd.luks.devices."luks-a226c66b-7561-47cd-96c2-3b24a7a92220".allowDiscards = true;

  boot.kernelParams = [
    # efi_pstore conflicts with ramoops below.
    # "efi_pstore.pstore_disable=1"
  ];

  # Enable to debug crashes.
  # boot.initrd.kernelModules = [ "ramoops" "netconsole" ];

  boot.extraModprobeConfig = ''
    # options ramoops memmap=0x2000000$0x188000000 ramoops.mem_address=0x188000000 ramoops.mem_size=0x2000000 ramoops.ecc=1 ramoops.record_size=0x200000 ramoops.console_size=0 ramoops.ftrace_size=0 ramoops.pmsg_size=0

    # This sends logs over to second-temple, if we are conneccted to Wifi.
    # options netconsole netconsole=9999@192.168.1.89/wlp1s0,9999@192.168.1.52/80:32:53:08:d3:b5

    # Who doesn't like fast virtualization.
    options kvm-amd avic=1 force_avic=1 nested=1
  '';

  # Hack
  services.fwupd.daemonSettings.OnlyTrusted = false;

  # Bootloader. We use lanzaboote.
  # boot.loader.systemd-boot.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;

  hardware.amdgpu.loadInInitrd = true;
  hardware.amdgpu.opencl = true;

  networking.hostName = "avalon";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Madrid";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
