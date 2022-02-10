{
  description = "System Configuration";

  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hercules-ci.url = "github:hercules-ci/hercules-ci-agent";
    rust-overlay.url = "github:oxalica/rust-overlay";

    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
      inputs = {
        inherit nixpkgs;
      };
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, hercules-ci, rust-overlay,
              tuxedo-nixos, flake-compat, flake-compat-ci }: {
    nixosConfigurations = {
      canaan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ ... }: {
            nixpkgs.overlays = [ rust-overlay.overlay ];

          })
          (import ./host/canaan/configuration.nix {
            pkgsUnstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          })

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
          ./host/babylon/configuration.nix
          ./host/babylon/hardware-configuration.nix

          tuxedo-nixos.nixosModule

          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-cpu-intel
        ];
      };

      first-temple = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./host/first-temple/configuration.nix
          ./host/first-temple/hardware-configuration.nix

          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel

          hercules-ci.nixosModules.agent-service
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

    # For Hercules CI, which doesn't natively support flakes (yet).
    ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
      flake = self;

      # Optional. Systems for which to perform CI.
      systems = [ "x86_64-linux" ];
    };
  };
}
