{
  description = "System Configuration";

  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hercules-ci.url = "github:hercules-ci/hercules-ci-agent";
    rust-overlay.url = "github:oxalica/rust-overlay";

    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, hercules-ci, rust-overlay,
              tuxedo-nixos }: {
    nixosConfigurations = {
      canaan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ({ ... }: { nixpkgs.overlays = [ rust-overlay.overlay ]; })

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
          ({ ... }: { nixpkgs.overlays = [ rust-overlay.overlay ]; })

          ./host/babylon/configuration.nix
          ./host/babylon/hardware-configuration.nix

          tuxedo-nixos.nixosModule

          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-cpu-intel
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
