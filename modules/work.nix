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

  environment.systemPackages = with pkgs; [
    # For merging PDFs
    pdftk

    # For testing
    qemu
  ] ++ (
    let
      qemuUefi = pkgs.writeShellScriptBin "qemu-uefi" ''
        exec ${pkgs.qemu}/bin/qemu-system-x86_64 \
              -machine q35,accel=kvm -cpu host -bios ${pkgs.OVMFFull.fd}/FV/OVMF.fd \
              -m 4096 -display none -serial stdio "$@"
      '';
      qemuUefiTftp = pkgs.writeShellScriptBin "qemu-uefi-tftp" ''
        exec ${qemuUefi}/bin/qemu-uefi \
              -boot n -device virtio-net,netdev=n1 -netdev user,id=n1,tftp=$HOME/Public/tftp,bootfile=ipxe.efi \
              "$@"
        '';
    in [
      qemuUefi
      qemuUefiTftp
    ]
  );

  virtualisation.libvirtd = {
    enable = true;

    qemu.ovmf.packages = with pkgs; [
      OVMFFull.fd

      # Only for AArch64 support.
      pkgsCross.aarch64-multiplatform.OVMF.fd
    ];
  };

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
