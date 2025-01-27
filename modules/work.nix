{ config, pkgs, lib, ... }: {

  nix = {
    settings.trusted-public-keys = [
      "cyberus-1:0jjMD2b+guloGW27ZToxDQApCoWj+4ONW9v8VH/Bv0Q="
      "binary-cache.vpn.cyberus-technology.de:qhg25lVqyCT4sDOqxY6GJx8NF3F86eAJFCQjZK/db7Y="
    ];

    settings.substituters = [
      "http://binary-cache-v2.vpn.cyberus-technology.de"
    ];

    extraOptions = ''
      extra-substituters = http://binary-cache-v2.vpn.cyberus-technology.de
   '';

    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "remote-builder.vpn.cyberus-technology.de";
        sshUser = "builder";
        systems = [ "x86_64-linux" "aarch64-linux" ];
        maxJobs = 8;
        supportedFeatures = [
          "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-x86-64-v2" "gccarch-x86-64-v3" "gccarch-x86-64-v4"
        ];
      }
    ];
  };

  # For cross-platform builds.
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  programs.ssh = {
    extraConfig = ''
      Host remote-builder.vpn.cyberus-technology.de
        PubkeyAcceptedKeyTypes ssh-ed25519
        IdentityFile ~/.ssh/id_ed25519
    '';

    knownHosts = {
      nixbuild = {
        hostNames = [ "remote-builder.vpn.cyberus-technology.de" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwdIPCDHFhao84ZoHgphp+hzYH9ot+L2gSDFD8HrMyw";
      };
    };
  };

  services.flatpak.enable = true;

  programs.evolution = {
    enable = true;
    plugins = [ pkgs.evolution-ews ];
  };

  programs.gnupg = {
    agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };

  environment.systemPackages = with pkgs; [
    gitlab-timelogs

    # For merging PDFs
    pdftk

    # For testing
    qemu

    # For flatpack
    gnome-software

    # Can't avoid those Word documents...
    libreoffice-fresh

    # For customer interaction
    citrix_workspace
  ] ++ (
    let
      qemuUefi = pkgs.writeShellScriptBin "qemu-uefi" ''
        exec ${pkgs.qemu}/bin/qemu-system-x86_64 \
          -machine q35,accel=kvm -cpu host -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
          "$@"
      '';
    in [
      qemuUefi
    ]
  );

  virtualisation.podman.enable = true;

  services = {
    onedrive.enable = true;
  };

  networking = {
    networkmanager = {
      enable = true;
    };
  };
}
