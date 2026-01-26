{ inputs, pkgs, ... }:
let
  image = pkgs.fetchurl {
    # You can pick any image here. We use a specific version (not "current"), so we can pin the dependency.
    url = "https://cloud-images.ubuntu.com/noble/20260108/noble-server-cloudimg-amd64.img";
    sha256 = "sha256-AHhsCTan3ZGmsHlBymC7VmUpdeDnL52s9zyIetpCCWY=";
  };
  imageRaw = pkgs.runCommand "ubuntu-image.raw" {
    nativeBuildInputs = [ pkgs.qemu-utils ];
  } ''
    qemu-img convert -O raw ${image} $out
  '';

  yaml = pkgs.formats.yaml { };
in {
  imports = [
    inputs.ctrl-os-modules.nixosModules.vms
  ];

  nixpkgs.overlays = [
    inputs.ctrl-os-modules.overlays.default
  ];

  networking.hostId = "12163d0e";

  ctrl-os.vms = {
    gatewayInterface = "enp3s0";

    networks.default = {
      externalIP = "192.168.10.2";
      gatewayIP = "192.168.20.1";

      allowedTCPPorts = [
        "2222:192.168.20.3:22"
      ];
    };

    virtualMachines = {
      demo = {
        # The image to boot (must be a RAW image for now).
        image = imageRaw; # We use the previously prepared disk image.
        imageSize = 4096; # Specify the disk size (MiB) of the virtual machine image here.

        # The characteristics of the VM.
        cores = 4; # Specify the amount of CPU cores the VM should have.
        memorySize = 8192; # MiB
        network = "default";

        # Start the VM at boot time.
        autoStart = true;

        cloudInitUserConfigFile = yaml.generate "cloud-init-user-config.yaml" {

          system_info.default_user.name = "nixos"; # The user name inside the virtual machine.
          password = "nixos"; # The initial password of the nixos user.

          # For demo and testing purposes only!
          chpasswd.expire = false; # Disable password expiry.
          ssh_pwauth = true; # Enable password authentication.

          # users = [
          #   {
          #     name = "julian";
          #     groups = [ "sudo" ];
          #     shell = "/bin/bash";
          #     sudo = "ALL=(ALL) NOPASSWD:ALL";
          #   }
          # ];

          # chpasswd = {
          #   list = [
          #     "julian:julian"
          #   ];
          #   expire = false;
          # };
        };

        cloudInitNetworkConfigFile = yaml.generate "cloud-init-network-config.yaml" {
          version = 2;
          ethernets.id0 = {
            # Configure the VM IP for every ethernet device starting with 'enp'
            match.name = "enp*";

            addresses = [
              "192.168.20.3/24"
            ];

            # Configure the internalIP of the network as gateway IP to allow internet access.
            gateway4 = "192.168.20.1";
          };
        };
      };
    };
  };
}
