{ inputs, pkgs, lib, ... }: {
  imports = [
    ../../modules/common.nix
    ../../modules/cachix.nix
    ../../modules/home-manager.nix

    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.ctrl-os-modules.nixosModules.profiles
    inputs.ctrl-os-modules.nixosModules.hardware

    ./disko.nix
  ];

  # Takes too long...
  documentation.man.generateCaches = false;

  # Booting waits for /dev/tpm0 and /dev/tpmrm0 otherwise and we don't have a TPM2...
  boot.initrd.systemd.tpm2.enable = false;
  systemd.tpm2.enable = false;

  services.displayManager.gdm = {
    enable = false;
    wayland = false;
  };

  services.desktopManager.gnome.enable = true;

  # The OOT modules want an LTS kernel.
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.consoleLogLevel = 7;

  ctrl-os.profiles.developer.enable = true;
  ctrl-os.hardware = {
    device = "nvidia-jetson-orin-nano-super";
  };

  nix.settings = {
    cores = 4;
    max-jobs = 2;
  };

  nix.settings.trusted-users = [ "nixremote" ];

  users.users.nixremote = {
    description = "Julian Stecklina";
    isNormalUser = true;
    extraGroups = [ "kvm" ];
    createHome = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ6YuhnQ7hdOuzwisoN636iJM/HDgyMNjQC74XyfVtq root@ms-a2"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeIiTyh7jJD9x8N64kgUGDgeo3F96i5Av3tHvwePHq5 julian@babylon"
    ];
  };

  systemd.network.enable = true;
  systemd.network.wait-online.enable = true;

  networking = {
    useNetworkd = true;
    useDHCP = false;
    interfaces.enP8p1s0.useDHCP = true;
  };

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "jetson";
  networking.domain = "localhost";

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
