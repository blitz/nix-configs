{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hercules-ci.url = "github:hercules-ci/hercules-ci-agent";
    rust-overlay.url = "github:oxalica/rust-overlay";
    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    riff = {
      url = "github:DeterminateSystems/riff";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    co2-exporter = {
      url = "github:blitz/co2-exporter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, hercules-ci, rust-overlay, dwarffs,
              tuxedo-nixos, riff, co2-exporter }: {
    nixosConfigurations = {
      canaan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ({ config, ... }: {
            nixpkgs.overlays = [ rust-overlay.overlays.default ];
            environment.systemPackages = [ riff.defaultPackage."${config.nixpkgs.system}" ];
          })

          ./host/canaan/configuration.nix
          ./host/canaan/hardware-configuration.nix

          # There is a Thinkpad L14 AMD module, but it disables the
          # IOMMU.
          nixos-hardware.nixosModules.lenovo-thinkpad
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-pc-laptop-acpi_call
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-gpu-amd
        ];
      };

      babylon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ({ config, ... }: {
            nixpkgs.overlays = [ rust-overlay.overlays.default ];
            environment.systemPackages = [ riff.defaultPackage."${config.nixpkgs.system}" ];
          })

          ./host/babylon/configuration.nix
          ./host/babylon/hardware-configuration.nix

          tuxedo-nixos.nixosModule

          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-cpu-intel

          # For debugging.
          dwarffs.nixosModules.dwarffs
        ];
      };

      second-temple = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./host/second-temple/configuration.nix
          ./host/second-temple/hardware-configuration.nix

          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel

          hercules-ci.nixosModules.agent-service
        ];
      };
    };
  };
}
