{ inputs, config, pkgs, lib, ... }: {

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
        systems = [
          "x86_64-linux"
          # Only has last resort. (Slow!)
          # "aarch64-linux"
        ];
        maxJobs = 8;
        supportedFeatures = [
          "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-x86-64-v2" "gccarch-x86-64-v3" "gccarch-x86-64-v4"
        ];
      }

      {
        hostName = "aarch64-01";
        protocol = "ssh-ng";
        systems = [ "aarch64-linux" ];
        maxJobs = 40;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
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

    # SBOMs
    inputs.sbomnix.packages.${pkgs.system}.sbomnix

    # For merging PDFs
    pdftk

    # For testing
    qemu

    # For flatpack
    gnome-software

    # Embedded development
    picocom
    rkdeveloptool
    attic-client
    b4
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

  virtualisation.virtualbox.host = {
    # enable = true;

    enableKvm = true;
    addNetworkInterface = false;
    enableExtensionPack = false;
    enableHardening = false;
  };

  services = {
    onedrive.enable = true;
  };

  networking = {
    networkmanager = {
      enable = true;
    };
  };
}
