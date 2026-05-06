{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{

  imports = [
    inputs.ctrl-os-modules.nixosModules.profiles
  ];

  ctrl-os.profiles.developer.enable = true;

  # For cross-platform builds.
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

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

  environment.systemPackages =
    with pkgs;
    [
      # gitlab-timelogs

      # For merging PDFs
      pdftk

      # For testing
      qemu
      # cloud-hypervisor

      # For flatpack
      gnome-software

      # Embedded development
      # picocom
      # rkdeveloptool
      # b4
    ]
    ++ (
      let
        qemuUefi = pkgs.writeShellScriptBin "qemu-uefi" ''
          exec ${lib.getExe' pkgs.qemu "qemu-system-x86_64"} \
            -machine q35,accel=kvm -cpu host -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
            "$@"
        '';

        # In newer Nixpkgs, the OVMF path will change.
        cloudHypervisorUefi = pkgs.writeShellScriptBin "cloud-hypervisor-uefi" ''
          exec ${lib.getExe pkgs.cloud-hypervisor} \
            --kernel ${pkgs.OVMF-cloud-hypervisor.fd}/FV/CLOUDHV.fd \
            "$@"
        '';
      in
      [
        qemuUefi
        # cloudHypervisorUefi
      ]
    );

  # virtualisation.podman.enable = true;

  services = {
    onedrive.enable = true;
  };
}
