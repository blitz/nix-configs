{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hercules-ci.url = "github:hercules-ci/hercules-ci-agent";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-parts.url = "github:hercules-ci/flake-parts";

    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, hercules-ci, rust-overlay, dwarffs, tuxedo-nixos,
                     flake-parts, hercules-ci-effects }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        hercules-ci-effects.flakeModule
      ];

      hercules-ci.flake-update = {
        enable = true;
        createPullRequest = false;

        when = {
          hour = 0;
        };
      };

      flake = {
        nixosConfigurations = {
          canaan = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              ({ config, ... }: {
                nixpkgs.overlays = [ rust-overlay.overlays.default ];
              })

              ./host/canaan/configuration.nix
              ./host/canaan/hardware-configuration.nix

              # There is a Thinkpad L14 AMD module, but it disables the
              # IOMMU.
              nixos-hardware.nixosModules.lenovo-thinkpad
              nixos-hardware.nixosModules.common-pc-laptop-ssd
              nixos-hardware.nixosModules.common-cpu-amd
              nixos-hardware.nixosModules.common-gpu-amd
            ];
          };

          babylon = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              ({ config, ... }: {
                nixpkgs.overlays = [ rust-overlay.overlays.default ];
                hardware.tuxedo-control-center.package = tuxedo-nixos.packages.x86_64-linux.default;
              })

              ./host/babylon/configuration.nix
              ./host/babylon/hardware-configuration.nix

              tuxedo-nixos.nixosModules.default

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

              # For debugging.
              dwarffs.nixosModules.dwarffs
            ];
          };
        };
      };
      systems = [
        "x86_64-linux"
      ];
      perSystem = { config, ... }: {
      };
    };
}
